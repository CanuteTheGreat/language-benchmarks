#!/bin/sh
# Every chart used in the blog series, from results/TAG-summary.csv. Run where matplotlib is
# available (in the langbench image: /usr/bin/python3, the distro Python).
#   make-charts.sh TAG
set -eu
TAG=${1:?tag}
here=$(cd "$(dirname "$0")/.." && pwd)
PY=${PY:-/usr/bin/python3}
C="$PY $here/harness/charts.py $TAG"
OUT="$here/results/charts/$TAG"
mkdir -p "$OUT"
# part 2: startup
$C hello --out "$OUT" --log
$C hello --metric rss --out "$OUT"
# parts 3-7: every single-threaded benchmark, time (log scale), memory and energy
for b in fib sieve collatz nbody spectralnorm mandelbrot fannkuchredux binarytrees fasta knucleotide revcomp \
         regexredux json hashmap quicksort sortstd dijkstra levenshtein matmul pidigits factorial; do
    $C $b --out "$OUT" --log
    $C $b --metric rss --out "$OUT"
    $C $b --metric energy --out "$OUT"
done
# part 8: multi-threaded
for b in mandelbrot spectralnorm fannkuchredux binarytrees; do
    $C $b --which mt --out "$OUT" --log
    $C $b --speedup --out "$OUT"
done
# relative (geometric mean vs C/GCC) per part and overall
$C --relative fib sieve collatz --title "Integers and recursion: time relative to C (GCC)" --out "$OUT"
$C --relative nbody spectralnorm mandelbrot --title "Floating point: time relative to C (GCC)" --out "$OUT"
$C --relative binarytrees hashmap --title "Allocation: time relative to C (GCC)" --out "$OUT"
$C --relative knucleotide revcomp regexredux json fasta --title "Text: time relative to C (GCC)" --out "$OUT"
$C --relative quicksort sortstd dijkstra levenshtein matmul pidigits factorial --title "Algorithms: time relative to C (GCC)" --out "$OUT"
$C --relative fib sieve collatz nbody spectralnorm mandelbrot fannkuchredux binarytrees fasta knucleotide revcomp \
   regexredux json hashmap quicksort sortstd dijkstra levenshtein matmul pidigits factorial \
   --title "All 21 programs: time relative to C (GCC)" --out "$OUT"
