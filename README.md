# language-benchmarks

The same programs written in ten languages, built and timed the same way on one machine:
C (GCC and Clang), C++, Rust, Zig, Go, Java, C#, JavaScript (Node.js), Python (CPython, plus PyPy)
and PHP (with and without the JIT).

This is the code and the raw data behind the "Language Showdown" series on
[blog.canutethegreat.com](https://blog.canutethegreat.com/). Everything needed to rerun it is here:
every implementation, the toolchain image, the harness, the raw measurements and the chart scripts.

## What is measured

Twenty-two programs (see [BENCHMARKS.md](BENCHMARKS.md) for the exact specification of each):

- the classic Computer Language Benchmarks Game set: n-body, spectral-norm, mandelbrot,
  fannkuch-redux, binary-trees, fasta, k-nucleotide, reverse-complement, regex-redux, pidigits
- well-known algorithms and maths: recursive Fibonacci, sieve of Eratosthenes, Collatz, matrix
  multiply, hand-written quicksort, standard-library sort, hash-map insert/lookup, Dijkstra,
  Levenshtein, JSON parse and serialise, big-number factorial
- hello world (startup time, build time, artifact size)
- multi-threaded versions of mandelbrot, spectral-norm, fannkuch-redux and binary-trees

Every implementation prints exactly the same bytes; `harness/run.py check` compares each one with
`expected/` before anything gets timed. The idiomatic version of each program is the code an
ordinary developer in that language would write. Same algorithm everywhere, standard library
first, no SIMD intrinsics, no tricks.

Per run: wall time, CPU time (user + system), peak resident memory, and CPU package energy from
Intel RAPL. Plus build time, artifact size and lines of code (tokei).

## Method

- One Docker image holds every toolchain (`docker/Dockerfile`, Arch Linux base because it ships
  current releases; CPython, .NET and Zig come from their upstream releases because the distro
  lagged). `results/raw/TAG/versions.txt` lists the exact versions used.
- The harness drives [hyperfine](https://github.com/sharkdp/hyperfine): 1 warm-up run, then 10
  timed runs per program, median reported along with min/max. A tiny wrapper (`docker/measure.c`)
  records peak RSS, CPU time and RAPL package energy for each run.
- Host prepared with `harness/host-setup.sh`: CPU governor `performance`, turbo boost off (a laptop
  that boosts for the first seconds and then throttles makes long-running programs look worse than
  short ones), nothing else running. Temperatures and clock speeds are logged every 2 s
  (`thermal.csv`).
- Single-threaded programs are pinned to the performance cores (`SINGLE_CPUS`); a runtime's own
  helper threads (JIT compiler, garbage collector) may use the second core, as they would on any
  real machine, and the CPU-time column shows how much they used. Multi-threaded programs get
  every CPU.
- Compiled languages are built with their usual release settings for the machine they run on:
  `-O3 -march=native` (C, C++), `cargo build --release` with `target-cpu=native`, Zig
  `ReleaseFast`, Go defaults with `GOAMD64=v3`, `dotnet publish -c Release`, plain `javac`.

## Reproduce

```sh
docker build -t langbench:dev docker/
docker run --rm -v "$PWD:/bench" langbench:dev python3 harness/run.py data      # input files
docker run --rm -v "$PWD:/bench" langbench:dev python3 harness/run.py check nbody
sudo harness/measure-all.sh mytag            # full run on the host (restores CPU settings afterwards)
python3 harness/summarize.py mytag           # -> results/mytag-summary.csv
python3 harness/charts.py mytag nbody --log  # -> results/charts/
```

## Layout

```
bench/NAME/LANG/       one implementation (LANG-mt = multi-threaded, LANG-opt = optimised variant)
expected/NAME.out      the output every implementation must print for the check input
harness/               run.py (build/check/measure), params.json (input sizes), summarize.py, charts.py
docker/                toolchain image and the measure wrapper
results/raw/TAG/       hyperfine JSON + per-run CSV for every program, host info, versions, thermal log
results/TAG-summary.csv  one row per benchmark and language
```

## Caveats

A benchmark measures one program on one machine. These numbers say how these implementations ran
on this laptop with these compilers; they don't say which language is "best", and a different
algorithm, input size, library or CPU can reorder the table. Programs that ran a fraction of a
second are dominated by startup for the JIT languages; the startup numbers are reported separately
so you can subtract them. Corrections and better idiomatic versions are welcome.

## Licence

MIT, see [LICENSE](LICENSE). The Benchmarks Game problem descriptions are by the Benchmarks Game
team; the implementations here were written for this project.
