#!/bin/sh
# Full measurement run on the benchmark HOST (as root). Needs the langbench image loaded.
#   measure-all.sh TAG [bench ...]
# Env: SINGLE_CPUS (default 0-3), MT_CPUS (default all), RUNS (10), WARMUP (1)
# Writes results/raw/TAG/... in the repo checkout; restores the host settings on exit.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
TAG=${1:?tag}; shift
BENCHES=$(echo ${*:-$(ls "$here/bench")})   # echo flattens the newlines from ls (they broke the sizes/buildtime loops)
SINGLE_CPUS=${SINGLE_CPUS:-0-3}
MT_CPUS=${MT_CPUS:-0-$(($(nproc) - 1))}
RUNS=${RUNS:-10}; WARMUP=${WARMUP:-1}
out="$here/results/raw/$TAG"; mkdir -p "$out"
lock="$here/results/raw/.measure.lock"
if ! mkdir "$lock" 2>/dev/null; then echo "another measure-all is running ($lock)"; exit 1; fi
IMG=${IMG:-langbench:dev}

sh "$here/harness/host-setup.sh" prepare > "$out/host-setup.txt"
sh "$here/harness/host-setup.sh" info > "$out/host-info.txt"
docker run --rm "$IMG" versions.sh > "$out/versions.txt" 2>&1
sh "$here/harness/throttle-counters.sh" before > "$out/throttle.txt"
sh "$here/harness/thermal-log.sh" "$out/thermal.csv" & tpid=$!
cleanup() {
    rmdir "$lock" 2>/dev/null
    kill $tpid 2>/dev/null
    docker kill "langbench-$$" >/dev/null 2>&1
    sh "$here/harness/throttle-counters.sh" after >> "$out/throttle.txt"
    sh "$here/harness/host-setup.sh" restore >> "$out/host-setup.txt"
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

run_in() {
    # (re)build the measure wrapper from this checkout so the image and the repo can't disagree
    docker run --rm --name "langbench-$$" --privileged --network none -v "$here:/bench" -e LB_RESULTS=/bench/results/raw "$IMG" \
        sh -c "gcc -O2 -o /usr/local/bin/measure /bench/docker/measure.c && $1" &
    wait $!   # waiting in the background keeps the shell responsive to signals (trap -> cleanup)
}
sh "$here/harness/container-overhead.sh" "$out" > "$out/container-overhead.txt" 2>&1
# idle power baseline: 3 x 20 s of sleep through the same wrapper
run_in "for i in 1 2 3; do taskset -c $SINGLE_CPUS measure -o results/raw/$TAG/idle.measure.csv -t idle -- sleep 20; done"
echo "$(date -Is) start $BENCHES" >> "$out/progress.log"
for b in $BENCHES; do
    echo "$(date -Is) bench $b" >> "$out/progress.log"
    r=$RUNS; w=$WARMUP
    [ "$b" = hello ] && r=50 && w=3     # startup times are tiny: more runs
    run_in "python3 harness/run.py data >/dev/null 2>&1; python3 harness/run.py measure $b --tag $TAG --runs $r --warmup $w --cpus $SINGLE_CPUS --mt-cpus $MT_CPUS" >> "$out/measure.log" 2>&1
done
run_in "for b in $BENCHES; do python3 harness/run.py sizes \$b --tag $TAG; done" >> "$out/measure.log" 2>&1
# build times (clean build, median of 5 after one warm-up build) for hello and a dependency-using program
for b in hello json; do
    case " $BENCHES " in *" $b "*) run_in "taskset -c $MT_CPUS python3 harness/run.py buildtime $b --runs 5 --tag $TAG" >> "$out/measure.log" 2>&1;; esac
done
echo "$(date -Is) done" >> "$out/progress.log"
