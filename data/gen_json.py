#!/usr/bin/env python3
"""Generate the deterministic input for the json benchmark: gen_json.py N OUTFILE.
Compact JSON, ASCII only, integers/strings/booleans/arrays (no floats, so every
language prints the numbers identically)."""
import json, sys

n, path = int(sys.argv[1]), sys.argv[2]
state = 42


def nxt():
    global state
    state = state * 48271 % 2147483647
    return state


recs = []
for i in range(n):
    recs.append({
        "id": i,
        "name": f"user{i}",
        "email": f"user{i}@example.com",
        "active": nxt() % 3 != 0,
        "score": nxt() % 100000,
        "tags": [f"t{nxt() % 50}" for _ in range(nxt() % 5)],
        "friends": [nxt() % n for _ in range(nxt() % 8)],
        "address": {"street": f"{nxt() % 9999} Main St", "zip": f"{nxt() % 100000:05d}"},
    })
with open(path, "w") as f:
    json.dump(recs, f, separators=(",", ":"))
