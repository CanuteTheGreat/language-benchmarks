# Benchmark specifications

Every implementation of a benchmark computes exactly the same thing and prints exactly the same
output, byte for byte. `harness/run.py check <bench>` builds every language and compares the
output with `expected/<bench>.out` (small "check" input) before anything is timed.

Rules for all implementations:

- **Idiomatic first.** Write the code the way a competent, ordinary developer in that language
  would write it for production: standard library first, the de-facto standard package where the
  standard library has nothing (listed per benchmark), no unsafe tricks, no SIMD intrinsics, no
  hand-written assembly, no lookup tables of precomputed answers, single-threaded unless the
  directory name ends in `-mt`.
- Same algorithm everywhere (described below). Data structures follow the language's normal
  choice (a `list` in Python, `Vec` in Rust, `ArrayList`/arrays in Java...).
- Input sizes come from the command line (`argv[1]`, `argv[2]`), never hard-coded. Input files
  for the text benchmarks arrive on **stdin** (or as a path in `argv[1]` for `json`).
- Output goes to stdout. Nothing else on stdout. Exit code 0.
- Optimised variants (`<lang>-opt`) are allowed to do what that language's community does when
  speed matters, and are reported separately and labelled as such.

## Shared pseudo-random generator (`minstd`)

Used by `quicksort`, `sortstd`, `hashmap`, `dijkstra`, `levenshtein`. It only needs 47-bit
intermediate values, so it is exact in every language (JavaScript doubles and PHP ints included):

```
state = seed            # seed given per benchmark
next():  state = (state * 48271) % 2147483647 ; return state     # 1 .. 2^31-2
```

## Benchmarks

### hello
Print `Hello, world!` and a newline. Used for startup time, binary size and build time.

### fib `N`
Naive recursive Fibonacci with 64-bit integers: `fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)`.
Print `fib(N)` as a decimal integer and a newline.

### sieve `N`
Sieve of Eratosthenes over a boolean/byte array of `N+1` entries (index = number). For each
`i` from 2 while `i*i <= N`: if `i` is still marked prime, mark `i*i, i*i+i, ... <= N` as
composite. Print the count of primes `<= N`. (Python's idiomatic bulk slice assignment
`a[i*i::i] = ...` is allowed for the inner marking loop, because that is how Python people
write a sieve; other languages use a plain loop.)

### collatz `N`
For every start value `1 <= s < N`, count the steps of the Collatz sequence until it reaches 1
(`n even -> n/2`, `n odd -> 3n+1`; 64-bit integers; no memoisation). Print the start value with
the most steps (smallest one on a tie) and its step count, separated by a space.

### nbody `N` / spectralnorm `N` / mandelbrot `N` / fannkuchredux `N` / binarytrees `N` / fasta `N` / knucleotide / revcomp / regexredux / pidigits `N`
Exactly as specified by the Computer Language Benchmarks Game
(https://benchmarksgame-team.pages.debian.net/benchmarksgame/description/<name>.html),
including its output format. Single-threaded in the idiomatic version.
`knucleotide`, `revcomp` and `regexredux` read the output of `fasta` from stdin.
- mandelbrot: plain scalar loop, 50 iterations, escape test `|z|^2 > 4.0`, binary PBM output.
- binarytrees: allocate real tree nodes (no arena/pool in the idiomatic version).
- pidigits: the Benchmarks Game spigot (same as the published programs) using the language's
  arbitrary-precision integers: C/C++ GMP, Rust `num-bigint`, Zig `std.math.big.int`, Go
  `math/big`, Java `BigInteger`, C# `System.Numerics.BigInteger`, JS `BigInt`, Python `int`,
  PHP `gmp`.
- regexredux: C PCRE2, C++ `std::regex`, Rust `regex`, Zig PCRE2 (via C import), Go `regexp`,
  Java `java.util.regex`, C# `System.Text.RegularExpressions`, JS `RegExp`, Python `re`, PHP
  `preg_*`.
- knucleotide: the language's standard hash map (C: a small hand-written open-addressing
  table, since C has none).

### matmul `N`
Two `N x N` matrices of 64-bit floats: `a[i][j] = (i + j) % 10`, `b[i][j] = (i * j) % 10`.
Compute `c = a * b` with the naive triple loop in **i, k, j** order
(`c[i][j] += a[i][k] * b[k][j]`). All values are small integers, so the result is exact.
Print the sum of all elements of `c` as an integer.

### quicksort `N`
Fill an array with `N` values from `minstd` (seed 42). Sort it in place with this hand-written
quicksort: `sort(lo, hi)` (inclusive): while `hi - lo >= 16`: pivot = median of
`a[lo], a[(lo+hi)/2], a[hi]` (by value); Hoare partition (`i = lo-1, j = hi+1`; do i++ while
`a[i] < p`; do j-- while `a[j] > p`; stop when `i >= j`, else swap) giving split `j`; recurse
into the smaller of `[lo, j]` / `[j+1, hi]` and loop on the larger. Finish ranges shorter than
16 with insertion sort. Then verify the array is sorted (exit 1 if not) and print
`a[0] a[N/2] a[N-1]` separated by spaces.

### sortstd `N`
Same data as `quicksort`, sorted with the language's standard-library sort for integers
(C `qsort`, C++ `std::sort`, Rust `sort_unstable` (idiomatic for ints), Zig `std.mem.sort`
(or `std.sort.pdq`), Go `slices.Sort`, Java `Arrays.sort(int[])`, C# `Array.Sort`, JS
`Int32Array.prototype.sort` or `Array.sort((a,b)=>a-b)` (whichever is idiomatic: use the plain
array with a comparator), Python `list.sort()`, PHP `sort()`). Same verification and output.

### hashmap `N`
Standard hash map from integer key to integer value. Generator `g1 = minstd(seed 42)`:
for `i` in `0..N-1`: `map[g1.next()] = i` (overwrite existing). Then `g2 = minstd(seed 4242)`:
for `j` in `0..N-1`: `k = g2.next()`; if `k` is in the map: `hits++`, `sum += map[k]`.
Print `size hits sum`. Map types: C hand-written open addressing (no stdlib map), C++
`std::unordered_map`, Rust `std::collections::HashMap` (default hasher), Zig
`std.AutoHashMap`, Go `map`, Java `HashMap<Integer,Integer>`, C# `Dictionary<int,int>`, JS
`Map`, Python `dict`, PHP `array`.

### dijkstra `V E`
`g = minstd(seed 42)`. Build a directed graph with `V` vertices and `E` edges: for each edge,
`u = g.next() % V`, then `v = g.next() % V`, then `w = g.next() % 100 + 1` (in that order);
adjacency lists, edges appended in generation order. Run Dijkstra from vertex 0 with a binary
heap priority queue and lazy deletion (skip popped entries whose distance is stale). Use the
standard library priority queue where there is one (C++ `std::priority_queue`, Rust
`BinaryHeap`, Zig `std.PriorityQueue`, Go `container/heap`, Java `PriorityQueue`, C#
`PriorityQueue`, Python `heapq`, PHP `SplPriorityQueue` or `SplMinHeap`); C and JS write a
small binary heap. Print `reached sum max`: number of reachable vertices (including 0), sum of
their distances, largest distance.

### levenshtein `L`
`g = minstd(seed 42)`. Build string `s` of `L` characters, each `"ACGT"[g.next() % 4]`, then
string `t` of `L` characters the same way (continuing the same generator). Compute the
Levenshtein edit distance with the classic two-row dynamic programme (insert, delete,
substitute all cost 1). Print the distance.

### json `FILE`
Read `FILE` (made by `data/gen_json.py`: an array of objects with integer, string, boolean and
array fields, compact, ASCII only). Parse it into the language's generic JSON tree (not a typed
struct), walk it: `count` = number of records, `active` = records with `"active": true`,
`score` = sum of all `"score"` fields. Then serialise the whole tree back to compact JSON
(no spaces) into a string. Print `count active score length` where `length` is the byte length
of the serialised string. Libraries: C cJSON, C++ nlohmann::json, Rust serde_json (`Value`),
Zig `std.json`, Go `encoding/json` (`any`), Java Jackson (`JsonNode`), C#
`System.Text.Json.Nodes`, JS `JSON`, Python `json`, PHP `json_decode`/`json_encode`.

### factorial `N`
Compute `N!` by multiplying an arbitrary-precision integer by 2, 3, ..., N in a simple loop
(no product tree), convert it to its decimal string, and print the number of digits and the
sum of the digits separated by a space. Same bignum libraries as `pidigits`. (Python must call
`sys.set_int_max_str_digits(0)`.)

## Multi-threaded variants (`<lang>-mt`)
`mandelbrot`, `spectralnorm`, `fannkuchredux`, `binarytrees`: same output as the
single-threaded version, using all CPUs the process is allowed to run on (ask the runtime: e.g.
`sched_getaffinity`/`nproc`, `available_parallelism`, `runtime.NumCPU`,
`Runtime.availableProcessors`, `Environment.ProcessorCount`, `os.availableParallelism`,
`os.process_cpu_count()`/`len(os.sched_getaffinity(0))`). Idiomatic parallel tool per language:
C OpenMP, C++ `std::thread`/`std::jthread`, Rust `rayon` or `std::thread::scope`, Zig
`std.Thread`, Go goroutines, Java threads/parallel streams, C# `Parallel.For`, JS
`worker_threads`, Python `multiprocessing`. PHP has no threads in its standard build and is
left out.
