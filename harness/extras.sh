#!/bin/sh
# Second pass on the benchmark HOST (as root), after measure-all.sh: artifact sizes and lines of code,
# clean build times, hardware performance counters and GC logs. Same host settings as measure-all.sh.
#   extras.sh TAG [bench ...]
# Writes results/raw/TAG/BENCH/sizes.json, results/raw/TAG/{hello,json}/buildtime.json and
# results/raw/TAG/extras/ (perf/, gc/, profile/, extras.log, host-setup.txt, thermal.csv).
# perf runs on the host and counts only the processes in the benchmark container's cgroup
# (perf stat -a --for-each-cgroup), so the counts include the few ms `docker exec` itself spends in there.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
TAG=${1:?tag}; shift
BENCHES=$(echo ${*:-$(ls "$here/bench")})      # echo flattens newlines into spaces
SINGLE_CPUS=${SINGLE_CPUS:-0-3}
MT_CPUS=${MT_CPUS:-0-$(($(nproc) - 1))}
IMG=${IMG:-langbench:dev}
out="$here/results/raw/$TAG"; ex="$out/extras"; mkdir -p "$ex/perf" "$ex/gc" "$ex/profile"
log="$ex/extras.log"
lock="$here/results/raw/.measure.lock"
if ! mkdir "$lock" 2>/dev/null; then echo "another measurement is running ($lock)"; exit 1; fi
C="langbench-extras-$$"

sh "$here/harness/host-setup.sh" prepare > "$ex/host-setup.txt"
sh "$here/harness/thermal-log.sh" "$ex/thermal.csv" & tpid=$!
cleanup() {
    rmdir "$lock" 2>/dev/null
    kill $tpid 2>/dev/null
    docker rm -f "$C" >/dev/null 2>&1
    sh "$here/harness/host-setup.sh" restore >> "$ex/host-setup.txt"
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP
step() { echo "$(date -Is) $*" >> "$ex/progress.log"; }

docker run -d --name "$C" --privileged --network none -v "$here:/bench" -w /bench -e LB_RESULTS=/bench/results/raw \
    "$IMG" sleep infinity > /dev/null
dx() { docker exec -w /bench "$C" sh -c "$1"; }
dx "gcc -O2 -o /usr/local/bin/measure /bench/docker/measure.c && python3 harness/run.py data >/dev/null 2>&1"

step sizes
for b in $BENCHES; do dx "python3 harness/run.py sizes $b --tag $TAG" >> "$log" 2>&1; done

step buildtime
for b in hello json; do
    case " $BENCHES " in *" $b "*) dx "taskset -c $MT_CPUS python3 harness/run.py buildtime $b --runs 5 --tag $TAG" >> "$log" 2>&1;; esac
done
# buildtime leaves the last build in place; rebuild nothing else (sizes built every variant already)

cid=$(docker inspect -f '{{.Id}}' "$C")
cgdir=$(find /sys/fs/cgroup -maxdepth 4 -type d -name "*$cid*" | head -1)
cg=${cgdir#/sys/fs/cgroup/}
echo "container cgroup: $cg" >> "$log"
EVENTS=cycles,instructions,branches,branch-misses,cache-references,cache-misses,L1-dcache-load-misses,dTLB-load-misses
if command -v perf >/dev/null 2>&1 && [ -n "$cg" ]; then
    perf --version >> "$log" 2>&1
    step perf-stat
    for b in $BENCHES; do
        [ "$b" = hello ] && continue
        mkdir -p "$ex/perf/$b"
        dx "python3 harness/run.py cmd $b" 2>>"$log" | grep -v -- '-mt	' > "$ex/perf/$b/cmds.tsv"
        while IFS="$(printf '\t')" read -r v cmd; do
            perf stat -x, -o "$ex/perf/$b/$v.csv" -a --for-each-cgroup "$cg" -e "$EVENTS" -- \
                docker exec -w /bench "$C" sh -c "taskset -c $SINGLE_CPUS $cmd > /dev/null" >> "$log" 2>&1 < /dev/null
        done < "$ex/perf/$b/cmds.tsv"
    done
    # sampled profiles of a few native programs (symbols resolved from copies of the container's files)
    step profile
    sym="$ex/profile/.symfs"; mkdir -p "$sym"
    for f in /usr/lib/libc.so.6 /usr/lib/libm.so.6 /usr/lib/libstdc++.so.6 /usr/lib/libgmp.so.10 /usr/lib/libpcre2-8.so.0 /usr/lib/ld-linux-x86-64.so.2; do
        mkdir -p "$sym$(dirname $f)"; docker cp -L "$C:$f" "$sym$f" 2>>"$log"
    done
    for bv in factorial:zig factorial:c-gcc pidigits:rust pidigits:c-gcc regexredux:cpp regexredux:go regexredux:rust \
              sortstd:c-gcc sortstd:cpp levenshtein:zig levenshtein:c-clang levenshtein:c-gcc fib:c-clang fib:c-gcc; do
        b=${bv%%:*}; v=${bv#*:}
        cmd=$(grep "^$v	" "$ex/perf/$b/cmds.tsv" | cut -f2-)
        [ -n "$cmd" ] || continue
        bin=$(echo "$cmd" | awk '{print $1}')
        mkdir -p "$sym$(dirname $bin)"; docker cp "$C:$bin" "$sym$bin" 2>>"$log"
        perf record -q -F 999 -a -e cpu_core/cycles/ -G "$cg" -o "$ex/profile/$b-$v.data" -- \
            docker exec -w /bench "$C" sh -c "taskset -c $SINGLE_CPUS $cmd > /dev/null" >> "$log" 2>&1 < /dev/null
        perf report -i "$ex/profile/$b-$v.data" --symfs "$sym" --no-children --sort dso,symbol --stdio --percent-limit 1 \
            > "$ex/profile/$b-$v.txt" 2>>"$log"
        rm -f "$ex/profile/$b-$v.data"
    done
    rm -rf "$sym"
else
    echo "perf not available on the host (or no cgroup found): counters skipped" >> "$log"
fi

step gc
c() { grep "^$2	" "$ex/perf/$1/cmds.tsv" 2>/dev/null | cut -f2- ; }
[ -s "$ex/perf/binarytrees/cmds.tsv" ] || dx "python3 harness/run.py cmd binarytrees" > "$ex/perf/binarytrees/cmds.tsv" 2>>"$log"
[ -s "$ex/perf/fasta/cmds.tsv" ] || dx "python3 harness/run.py cmd fasta" > "$ex/perf/fasta/cmds.tsv" 2>>"$log"
J=$(c binarytrees java | sed 's/^java /java -Xlog:gc*:file=results\/raw\/'"$TAG"'\/extras\/gc\/java-binarytrees.log /')
dx "taskset -c $SINGLE_CPUS $J > /dev/null" >> "$log" 2>&1
dx "GODEBUG=gctrace=1 taskset -c $SINGLE_CPUS $(c binarytrees go) > /dev/null 2> results/raw/$TAG/extras/gc/go-binarytrees.log" >> "$log" 2>&1
dx "taskset -c $SINGLE_CPUS $(c binarytrees js | sed 's/^node /node --trace-gc /') > results/raw/$TAG/extras/gc/js-binarytrees.log" >> "$log" 2>&1
dx "taskset -c $SINGLE_CPUS $(c fasta js | sed 's/^node /node --trace-gc /') | grep -a -E 'Scavenge|Mark-Compact|Minor|Major' > results/raw/$TAG/extras/gc/js-fasta.log" >> "$log" 2>&1
# C# binary-trees, Parallel.For: workstation GC (the default for console apps) vs server GC, same session
CM=$(dx "python3 harness/run.py cmd binarytrees csharp-mt csharp" 2>>"$log")
CMT=$(echo "$CM" | grep '^csharp-mt	' | cut -f2-); CST=$(echo "$CM" | grep '^csharp	' | cut -f2-)
dx "hyperfine -N --style basic --warmup 1 --runs 10 --output null --export-json results/raw/$TAG/extras/gc/csharp-gc-modes.json \
    -n mt-workstation 'taskset -c $MT_CPUS $CMT' \
    -n mt-server 'env DOTNET_gcServer=1 taskset -c $MT_CPUS $CMT' \
    -n mt-workstation-nonconcurrent 'env DOTNET_gcConcurrent=0 taskset -c $MT_CPUS $CMT' \
    -n single-workstation 'taskset -c $SINGLE_CPUS $CST' \
    -n single-server 'env DOTNET_gcServer=1 taskset -c $SINGLE_CPUS $CST'" >> "$log" 2>&1
step done
