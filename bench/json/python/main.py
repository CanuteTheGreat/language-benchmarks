# json - parse, walk and re-serialise with the json module
import json
import sys


def main():
    with open(sys.argv[1], encoding="utf-8") as f:
        root = json.load(f)

    count = 0
    active = 0
    score = 0
    for rec in root:
        count += 1
        if rec["active"] is True:
            active += 1
        score += rec["score"]

    out = json.dumps(root, separators=(",", ":"))
    print(count, active, score, len(out.encode("utf-8")))


main()
