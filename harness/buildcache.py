#!/usr/bin/env python3
"""Build time with and without each toolchain's shared caches, for hello world. Runs inside the container.
Complements `run.py buildtime` (which deletes the output dir but leaves the toolchains' global caches alone,
except Zig, whose cache dirs live inside the output dir):

  zig  warm: keep a filled --global-cache-dir between builds (only the local cache is deleted)
  go   cold: `go clean -cache` before every build
  csharp cold: `dotnet build-server shutdown` before every build (no warm compiler server)
  rust cold-std: not measurable here (the standard library ships precompiled), skipped

  buildcache.py TAG [--runs 5]  -> results/raw/TAG/hello/buildtime-cache.json
"""
import json, os, shutil, subprocess, sys, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "harness"))
import run  # noqa: E402

tag = sys.argv[1]
runs = int(sys.argv[sys.argv.index("--runs") + 1]) if "--runs" in sys.argv else 5
B = "hello"
res = []


def timed(variant, before=None, patch=None):
    cmds, cwd = run.build_cmd(B, variant)
    if patch:
        cmds = patch(cmds)
    times = []
    for i in range(runs + 1):
        o = run.out_dir(B, variant)
        shutil.rmtree(o, ignore_errors=True)
        os.makedirs(o, exist_ok=True)
        if before:
            subprocess.run(before, shell=True, capture_output=True)
        t = time.time()
        for c in cmds:
            subprocess.run(c, cwd=cwd, env=run.env_for(variant), check=True, capture_output=True)
        if i > 0:
            times.append(time.time() - t)
    times.sort()
    return times


zg = "/tmp/zig-global-warm"
shutil.rmtree(zg, ignore_errors=True)


def zig_warm(cmds):
    c = list(cmds[0])
    i = c.index("--global-cache-dir")
    c[i + 1] = zg
    return [c]


t = timed("zig", patch=zig_warm)
res.append({"variant": "zig", "mode": "warm global cache", "times": t, "median": t[len(t) // 2]})
t = timed("go", before="go clean -cache")
res.append({"variant": "go", "mode": "cold build cache (go clean -cache)", "times": t, "median": t[len(t) // 2]})
t = timed("csharp", before="dotnet build-server shutdown")
res.append({"variant": "csharp", "mode": "no build server (dotnet build-server shutdown)", "times": t, "median": t[len(t) // 2]})
for r in res:
    print(f"{r['variant']} {r['mode']}: median {r['median']:.2f}s {['%.2f' % x for x in r['times']]}")
json.dump(res, open(os.path.join(run.RESULTS, tag, B, "buildtime-cache.json"), "w"), indent=1)
