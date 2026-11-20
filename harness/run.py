#!/usr/bin/env python3
"""Build, check and measure every implementation. Runs inside the langbench container.

  run.py list
  run.py build   BENCH [VARIANT...]
  run.py check   BENCH [VARIANT...]        build + compare output with expected/BENCH.out
  run.py measure BENCH [VARIANT...] [--runs 10] [--warmup 1] [--cpus 2,6] [--tag NAME]
  run.py buildtime BENCH [VARIANT...] [--runs 5]
  run.py sizes   BENCH [VARIANT...]       artifact size + lines of code
  run.py data                             generate the input files in data/
  run.py cmd     BENCH [VARIANT...]       print VARIANT<TAB>shell command line (used by extras.sh)

VARIANT = c-gcc, c-clang, cpp, rust, zig, go, java, csharp, js, python, pypy, php, php-jit,
optionally with a -mt or -opt suffix (source directory bench/BENCH/<lang>-mt etc.).
"""
import argparse, glob, hashlib, json, os, shutil, subprocess, sys, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BENCH = os.path.join(ROOT, "bench")
BUILD = os.environ.get("LB_BUILD", "/tmp/lb-build")
RESULTS = os.environ.get("LB_RESULTS", os.path.join(ROOT, "results", "raw"))
DATA = os.path.join(ROOT, "data")
PARAMS = json.load(open(os.path.join(ROOT, "harness", "params.json")))

BASE_VARIANTS = ["c-gcc", "c-clang", "cpp", "rust", "zig", "go", "java", "csharp",
                 "js", "python", "pypy", "php", "php-jit"]
SRC_LANG = {"c-gcc": "c", "c-clang": "c", "pypy": "python", "php-jit": "php"}
NATIVE = "-march=native"
JAVA_CP = "/opt/java-libs/*"
PHP_JIT = ["-d", "opcache.enable_cli=1", "-d", "opcache.jit=tracing", "-d", "opcache.jit_buffer_size=128M"]


def split_variant(v):
    for suf in ("-mt", "-opt"):
        if v.endswith(suf):
            return v[: -len(suf)], suf
    return v, ""


def src_dir(bench, variant):
    base, suf = split_variant(variant)
    return os.path.join(BENCH, bench, SRC_LANG.get(base, base) + suf)


def out_dir(bench, variant):
    return os.path.join(BUILD, bench, variant)


def flags(sdir):
    f = os.path.join(sdir, "flags")
    return open(f).read().split() if os.path.exists(f) else []


def available(bench):
    out = []
    for v in BASE_VARIANTS:
        for suf in ("", "-mt", "-opt"):
            if os.path.isdir(src_dir(bench, v + suf)):
                out.append(v + suf)
    return out


def build_cmd(bench, variant):
    """Return (list of shell commands as argv lists, cwd) that build the variant from scratch."""
    base, _ = split_variant(variant)
    s, o = src_dir(bench, variant), out_dir(bench, variant)
    fl = flags(s)
    if base in ("c-gcc", "c-clang"):
        cc = "gcc" if base == "c-gcc" else "clang"
        extra = ["-fopenmp"] if variant.endswith("-mt") else []
        return [[cc, "-O3", NATIVE, *extra, "-o", f"{o}/main", "main.c", "-lm", *fl]], s
    if base == "cpp":
        return [["g++", "-O3", NATIVE, "-std=c++23", "-o", f"{o}/main", "main.cpp", "-pthread", *fl]], s
    if base == "rust":
        return [["cargo", "build", "--release", "--offline", "--quiet", "--target-dir", f"{o}/target"]], s
    if base == "zig":
        return [["zig", "build-exe", "-O", "ReleaseFast", f"-femit-bin={o}/main", "--cache-dir", f"{o}/zig-cache",
                 "--global-cache-dir", f"{o}/zig-global", "main.zig", *fl]], s
    if base == "go":
        return [["go", "build", "-o", f"{o}/main", "."]], s
    if base == "java":
        return [["javac", "-d", o, "-cp", JAVA_CP, *sorted(glob.glob(os.path.join(s, "*.java")))]], s
    if base == "csharp":
        return [["dotnet", "publish", "-c", "Release", "--nologo", "-v", "q", "-o", o,
                 "-p:BaseIntermediateOutputPath=" + o + "/obj/", "-p:BaseOutputPath=" + o + "/bin/"]], s
    return [], s  # interpreted: nothing to build


def run_cmd(bench, variant):
    base, _ = split_variant(variant)
    s, o = src_dir(bench, variant), out_dir(bench, variant)
    if base in ("c-gcc", "c-clang", "cpp", "zig", "go"):
        return [f"{o}/main"]
    if base == "rust":
        return [f"{o}/target/release/bench"]
    if base == "java":
        return ["java", "-cp", f"{o}:{JAVA_CP}", "Main"]
    if base == "csharp":
        dll = [p for p in glob.glob(f"{o}/*.dll") if os.path.exists(p[:-4] + ".runtimeconfig.json")]
        return [dll[0][:-4]]  # the apphost next to the dll
    if base == "js":
        return ["node", f"{s}/main.js"]
    if base == "python":
        return ["python3", f"{s}/main.py"]
    if base == "pypy":
        return ["pypy3", f"{s}/main.py"]
    if base == "php":
        return ["php", f"{s}/main.php"]
    if base == "php-jit":
        return ["php", *PHP_JIT, f"{s}/main.php"]
    raise SystemExit(f"unknown variant {variant}")


def env_for(variant):
    e = dict(os.environ)
    if split_variant(variant)[0] == "rust":
        e["RUSTFLAGS"] = "-C target-cpu=native"
    return e


def build(bench, variant, quiet=False):
    o = out_dir(bench, variant)
    shutil.rmtree(o, ignore_errors=True)
    os.makedirs(o, exist_ok=True)
    cmds, cwd = build_cmd(bench, variant)
    t = time.time()
    for c in cmds:
        r = subprocess.run(c, cwd=cwd, env=env_for(variant), capture_output=True, text=True)
        if r.returncode != 0:
            print(f"BUILD FAIL {bench}/{variant}: {' '.join(c)}\n{r.stdout[-3000:]}\n{r.stderr[-3000:]}")
            return False
    if not quiet:
        print(f"built {bench}/{variant} in {time.time()-t:.1f}s")
    return True


def args_for(bench, kind):
    p = PARAMS[bench]
    a = [str(x) for x in p.get(kind, [])]
    a = [os.path.join(DATA, x[5:]) if x.startswith("data:") else x for x in a]
    stdin = p.get(kind + "_stdin")
    return a, (os.path.join(DATA, stdin) if stdin else None)


def check(bench, variants):
    exp_path = os.path.join(ROOT, "expected", bench + ".out")
    expected = open(exp_path, "rb").read() if os.path.exists(exp_path) else None
    ok = True
    for v in variants:
        if not build(bench, v, quiet=True):
            ok = False
            continue
        a, stdin = args_for(bench, "check")
        t = time.time()
        r = subprocess.run(run_cmd(bench, v) + a, stdin=open(stdin, "rb") if stdin else subprocess.DEVNULL,
                           capture_output=True, timeout=600)
        dt = time.time() - t
        got = r.stdout
        if expected is None:
            os.makedirs(os.path.dirname(exp_path), exist_ok=True)
            open(exp_path, "wb").write(got)
            expected = got
            print(f"NOTE wrote {exp_path} from {v}")
        status = "OK" if (got == expected and r.returncode == 0) else "MISMATCH"
        if status != "OK":
            ok = False
            print(f"{status} {bench}/{v} rc={r.returncode} {dt:.2f}s\n  got  {got[:200]!r}\n  want {expected[:200]!r}\n  err  {r.stderr[-800:]!r}")
        else:
            print(f"OK {bench}/{v} {dt:.2f}s md5={hashlib.md5(got).hexdigest()}")
    return ok


def measure(bench, variants, runs, warmup, cpus, tag, kind="run", mt_cpus=None):
    outd = os.path.join(RESULTS, tag, bench)
    os.makedirs(outd, exist_ok=True)
    for v in variants:
        if not os.path.exists(out_dir(bench, v)) or split_variant(v)[0] in ("java", "csharp") and not os.listdir(out_dir(bench, v)):
            build(bench, v, quiet=True)
        a, stdin = args_for(bench, kind)
        csv = os.path.join(outd, f"{v}.measure.csv")
        js = os.path.join(outd, f"{v}.hyperfine.json")
        if os.path.exists(js):
            print(f"skip {bench}/{v} (done)")
            continue
        if os.path.exists(csv):
            os.remove(csv)
        use = mt_cpus if (mt_cpus and v.endswith("-mt")) else cpus
        cmd = ["taskset", "-c", use, "measure", "-o", csv, "-t", v, "--"] + run_cmd(bench, v) + a
        hf = ["hyperfine", "-N", "--style", "basic", "--warmup", str(warmup), "--runs", str(runs),
              "--export-json", js + ".tmp", "--output", "null" if bench != "hello" else "pipe"]
        if stdin:
            hf += ["--input", stdin]
        hf += ["--command-name", v, " ".join(shlex_quote(x) for x in cmd)]
        print(f"measure {bench}/{v}: {' '.join(cmd)}", flush=True)
        r = subprocess.run(hf, env=env_for(v))
        if r.returncode == 0:
            os.replace(js + ".tmp", js)
        else:
            print(f"MEASURE FAIL {bench}/{v} rc={r.returncode}")


def shlex_quote(s):
    import shlex
    return shlex.quote(s)


def buildtime(bench, variants, runs, tag):
    outd = os.path.join(RESULTS, tag, bench)
    os.makedirs(outd, exist_ok=True)
    rows = []
    for v in variants:
        cmds, cwd = build_cmd(bench, v)
        if not cmds:
            continue
        times = []
        for i in range(runs + 1):
            o = out_dir(bench, v)
            shutil.rmtree(o, ignore_errors=True)
            os.makedirs(o, exist_ok=True)
            t = time.time()
            for c in cmds:
                subprocess.run(c, cwd=cwd, env=env_for(v), check=True, capture_output=True)
            if i > 0:  # first build is a warm-up (fills OS caches)
                times.append(time.time() - t)
        times.sort()
        rows.append({"variant": v, "times": times, "median": times[len(times) // 2]})
        print(f"buildtime {bench}/{v}: median {rows[-1]['median']:.2f}s")
    json.dump(rows, open(os.path.join(outd, "buildtime.json"), "w"), indent=1)


def artifact_size(bench, v):
    base, _ = split_variant(v)
    o, s = out_dir(bench, v), src_dir(bench, v)
    if base in ("c-gcc", "c-clang", "cpp", "zig", "go", "rust"):
        p = run_cmd(bench, v)[0]
        st = p + ".stripped"
        shutil.copy(p, st)
        subprocess.run(["strip", st], check=False)
        return os.path.getsize(p), os.path.getsize(st)
    if base == "java":
        n = sum(os.path.getsize(f) for f in glob.glob(f"{o}/**/*.class", recursive=True))
        return n, n
    if base == "csharp":
        n = sum(os.path.getsize(f) for f in glob.glob(f"{o}/*.dll"))
        return n, n
    n = sum(os.path.getsize(f) for f in glob.glob(f"{s}/*") if os.path.isfile(f))
    return n, n


def loc(bench, v):
    s = src_dir(bench, v)
    r = subprocess.run(["tokei", "-o", "json", s], capture_output=True, text=True)
    try:
        d = json.loads(r.stdout)
        return sum(x["code"] for k, x in d.items() if k not in ("Total", "TOML", "Json", "XML", "MSBuild", "Plain Text"))
    except Exception:
        return None


def sizes(bench, variants, tag):
    outd = os.path.join(RESULTS, tag, bench)
    os.makedirs(outd, exist_ok=True)
    rows = []
    for v in variants:
        if not os.path.exists(out_dir(bench, v)):
            build(bench, v, quiet=True)
        size, stripped = artifact_size(bench, v)
        rows.append({"variant": v, "artifact_bytes": size, "stripped_bytes": stripped, "loc": loc(bench, v)})
        print(rows[-1])
    json.dump(rows, open(os.path.join(outd, "sizes.json"), "w"), indent=1)


def data():
    os.makedirs(DATA, exist_ok=True)
    build("fasta", "c-gcc", quiet=True)
    for n in sorted({int(x) for p in PARAMS.values() for k in ("check_stdin", "run_stdin")
                     if (x := (p.get(k) or "").removeprefix("fasta-").removesuffix(".txt")).isdigit()}):
        f = os.path.join(DATA, f"fasta-{n}.txt")
        if not os.path.exists(f):
            with open(f, "wb") as fh:
                subprocess.run(run_cmd("fasta", "c-gcc") + [str(n)], stdout=fh, check=True)
            print("made", f)
    for x in (PARAMS["json"]["check"] + PARAMS["json"]["run"]):
        name = x[5:]
        f = os.path.join(DATA, name)
        if not os.path.exists(f):
            n = int(name.split("-")[1].split(".")[0])
            subprocess.run([sys.executable, os.path.join(DATA, "gen_json.py"), str(n), f], check=True)
            print("made", f)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd")
    ap.add_argument("bench", nargs="?")
    ap.add_argument("variants", nargs="*")
    ap.add_argument("--runs", type=int, default=10)
    ap.add_argument("--warmup", type=int, default=1)
    ap.add_argument("--cpus", default="0-3")
    ap.add_argument("--mt-cpus", default=None)
    ap.add_argument("--tag", default="dev")
    ap.add_argument("--kind", default="run")
    a = ap.parse_args()
    if a.cmd == "list":
        for b in sorted(os.listdir(BENCH)):
            print(b, " ".join(available(b)))
        return
    if a.cmd == "data":
        return data()
    vs = a.variants or available(a.bench)
    if a.cmd == "build":
        sys.exit(0 if all([build(a.bench, v) for v in vs]) else 1)
    if a.cmd == "check":
        sys.exit(0 if check(a.bench, vs) else 1)
    if a.cmd == "measure":
        return measure(a.bench, vs, a.runs, a.warmup, a.cpus, a.tag, a.kind, a.mt_cpus)
    if a.cmd == "time1":  # one untimed-harness run at the given size, for calibrating sizes
        for v in vs:
            if not build(a.bench, v, quiet=True):
                continue
            args, stdin = args_for(a.bench, a.kind)
            t = time.time()
            r = subprocess.run(run_cmd(a.bench, v) + args, stdin=open(stdin, "rb") if stdin else subprocess.DEVNULL,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=900)
            print(f"time1 {a.bench}/{v} {time.time()-t:.2f}s rc={r.returncode} out={r.stdout[:80]!r}", flush=True)
        return
    if a.cmd == "cmd":  # print the shell command line that runs each (built) variant, one per line: VARIANT<TAB>CMD
        for v in vs:
            if not os.path.exists(out_dir(a.bench, v)):
                build(a.bench, v, quiet=True)
            args, stdin = args_for(a.bench, a.kind)
            line = " ".join(shlex_quote(x) for x in run_cmd(a.bench, v) + args)
            print(f"{v}\t{line}" + (f" < {shlex_quote(stdin)}" if stdin else ""))
        return
    if a.cmd == "buildtime":
        return buildtime(a.bench, vs, a.runs, a.tag)
    if a.cmd == "sizes":
        return sizes(a.bench, vs, a.tag)
    raise SystemExit(__doc__)


if __name__ == "__main__":
    main()
