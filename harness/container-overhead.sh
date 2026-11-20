#!/bin/sh
# Compare the same static binaries run on the host and inside the benchmark container.
#   container-overhead.sh OUTDIR     (run as root on the host, after host-setup.sh prepare)
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
out=${1:?outdir}; mkdir -p "$out"
IMG=${IMG:-langbench:dev}
CPUS=${SINGLE_CPUS:-0-3}
docker run --rm -v "$here:/bench" "$IMG" sh -c "mkdir -p /bench/ovh && \
  gcc -O3 -march=native -static -o /bench/ovh/fib bench/fib/c/main.c && \
  gcc -O2 -static -o /bench/ovh/hello bench/hello/c/main.c && \
  gcc -O2 -static -o /bench/ovh/measure docker/measure.c"
loop() {  # where tag n cmd...
    where=$1; tag=$2; n=$3; shift 3
    if [ "$where" = host ]; then
        i=0; while [ $i -lt $n ]; do taskset -c $CPUS "$here/ovh/measure" -o "$out/overhead.csv" -t "$tag" -- "$@" > /dev/null; i=$((i+1)); done
    else
        docker run --rm --privileged --network none -v "$here:/bench" -v "$out:/out" "$IMG" sh -c \
          "i=0; while [ \$i -lt $n ]; do taskset -c $CPUS /bench/ovh/measure -o /out/overhead.csv -t $tag -- $* > /dev/null; i=\$((i+1)); done"
    fi
}
for round in 1 2; do
    loop host fib-host 6 "$here/ovh/fib" 40
    loop container fib-container 6 /bench/ovh/fib 40
    loop host hello-host 50 "$here/ovh/hello"
    loop container hello-container 50 /bench/ovh/hello
done
rm -rf "$here/ovh"
python3 - "$out/overhead.csv" <<'EOF'
import csv, statistics, sys
d = {}
for r in csv.reader(open(sys.argv[1])):
    d.setdefault(r[0], []).append(float(r[1]))
for k, v in sorted(d.items()):
    print(f"{k}: n={len(v)} median={statistics.median(v)*1000:.3f} ms min={min(v)*1000:.3f} max={max(v)*1000:.3f}")
EOF
