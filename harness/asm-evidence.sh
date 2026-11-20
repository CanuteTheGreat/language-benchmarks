#!/bin/sh
# Assembly evidence for the blog posts: compile small kernels the way run.py does, but with
# -march=raptorlake (the benchmark laptop's core, so this can run on any x86 host) and summarise.
# Run inside the langbench container:  sh harness/asm-evidence.sh > results/asm-evidence.txt
set -u
cd /bench
T=/tmp/asm; rm -rf $T; mkdir -p $T
A="-O3 -march=raptorlake"
for b in fib collatz mandelbrot spectralnorm nbody matmul levenshtein sieve; do
    F=$(cat bench/$b/c/flags 2>/dev/null | tr ' ' '\n' | grep -v '^-l' | tr '\n' ' ')
    gcc $A $F -S -o $T/$b-gcc.s bench/$b/c/main.c 2>/dev/null
    clang $A $F -S -o $T/$b-clang.s bench/$b/c/main.c 2>/dev/null
done
count() { # file pattern
    n=$(grep -cE "$2" "$1" 2>/dev/null); echo "${n:-0}"
}
echo "## fib: call instructions to fib in the generated assembly (whole file)"
for c in gcc clang; do echo "$c: calls=$(grep -cE 'callq?\s+_?fib' $T/fib-$c.s) lines=$(wc -l < $T/fib-$c.s)"; done
echo
echo "## collatz: conditional moves and conditional jumps in main"
for c in gcc clang; do
    awk '/^main:/,/\.cfi_endproc/' $T/collatz-$c.s > $T/collatz-$c.main
    echo "$c: cmov=$(count $T/collatz-$c.main 'cmov') jcc=$(count $T/collatz-$c.main '^\s+j(n?e|n?z|n?s|a|b|ae|be|g|l|ge|le)\s')"
done
echo
for b in mandelbrot spectralnorm nbody matmul levenshtein sieve; do
    echo "## $b: vector instructions (ymm = 256-bit AVX, xmm packed = 128-bit) vs scalar double ops"
    for c in gcc clang; do
        f=$T/$b-$c.s
        echo "$c: ymm_insns=$(count $f '%ymm') packed_pd=$(count $f 'v[a-z]+pd\s') scalar_sd=$(count $f 'v[a-z]+sd\s') fma=$(count $f 'vfmadd|vfnmadd') vpcmp/vpmin/vpminud=$(count $f 'vpmin|vpcmp')"
    done
    echo
done
# Rust and Zig matmul / levenshtein / mandelbrot / nbody (emit asm)
for b in matmul levenshtein mandelbrot nbody spectralnorm; do
    (cd bench/$b/rust && RUSTFLAGS="-C target-cpu=raptorlake --emit=asm" cargo build --release --offline --quiet --target-dir $T/rust-$b 2>&1 | tail -3)
    f=$(ls $T/rust-$b/release/deps/bench-*.s 2>/dev/null | head -1)
    [ -n "$f" ] && echo "rust $b: ymm_insns=$(count $f '%ymm') packed_pd=$(count $f 'v[a-z]+pd\s') scalar_sd=$(count $f 'v[a-z]+sd\s') fma=$(count $f 'vfmadd|vfnmadd') panic_bounds_check_calls=$(count $f 'panic_bounds_check')"
    zig build-obj -O ReleaseFast -mcpu=raptorlake -femit-asm=$T/$b-zig.s -fno-emit-bin --cache-dir $T/zc --global-cache-dir $T/zg bench/$b/zig/main.zig >/dev/null 2>&1
    f=$T/$b-zig.s
    [ -f $f ] && echo "zig $b: ymm_insns=$(count $f '%ymm') packed_pd=$(count $f 'v[a-z]+pd\s') scalar_sd=$(count $f 'v[a-z]+sd\s') fma=$(count $f 'vfmadd|vfnmadd')"
done
echo
echo "## C mandelbrot / nbody / spectralnorm flags files"
for b in mandelbrot nbody spectralnorm matmul; do printf '%s c/flags: %s | cpp/flags: %s\n' $b "$(cat bench/$b/c/flags 2>/dev/null)" "$(cat bench/$b/cpp/flags 2>/dev/null)"; done
