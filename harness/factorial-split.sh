#!/bin/sh
# Side experiment for the blog: how much of Zig's factorial time is the multiplication loop and how much the
# decimal conversion? Builds the Zig program twice (as is, and with toString removed) plus the GMP C version,
# and times all three with hyperfine. Run inside the container:  sh harness/factorial-split.sh
set -eu
T=/tmp/fz; rm -rf $T; mkdir -p $T; cd $T
gcc -O3 -march=native -o cfact /bench/bench/factorial/c/main.c -lgmp
cp /bench/bench/factorial/zig/main.zig full.zig
sed 's/const s = try f.toString(gpa, 10, .lower);/const s = "0"; std.mem.doNotOptimizeAway(f.limbs.len);/; s/defer gpa.free(s);//' full.zig > mulonly.zig
for v in full mulonly; do zig build-exe -O ReleaseFast -femit-bin=$T/$v --cache-dir $T/c --global-cache-dir $T/g $v.zig; done
hyperfine -N --style basic --warmup 1 --runs 5 -n c-gmp "$T/cfact 100000" -n zig-full "$T/full 100000" -n zig-multiply-only "$T/mulonly 100000"
