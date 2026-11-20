# knucleotide - Python
import sys

LETTERS = "ACGT"
TABLE = bytes.maketrans(b"ACGT", b"\x00\x01\x02\x03")


def count(s, k):
    d = {}
    mask = (1 << (2 * k)) - 1
    key = 0
    for i, c in enumerate(s):
        key = ((key << 2) | c) & mask
        if i + 1 >= k:
            d[key] = d.get(key, 0) + 1
    return d


def name(key, k):
    return "".join(LETTERS[(key >> (2 * (k - 1 - j))) & 3] for j in range(k))


def frequencies(out, s, k):
    d = count(s, k)
    total = len(s) - k + 1
    for key, cnt in sorted(d.items(), key=lambda kv: (-kv[1], kv[0])):
        out.append("%s %.3f\n" % (name(key, k), 100.0 * cnt / total))
    out.append("\n")


def occurrences(out, s, seq):
    key = 0
    for ch in seq:
        key = (key << 2) | LETTERS.index(ch)
    out.append("%d\t%s\n" % (count(s, len(seq)).get(key, 0), seq))


def main():
    parts = []
    three = False
    for line in sys.stdin.buffer.read().split(b"\n"):
        if line.startswith(b">"):
            three = line.startswith(b">THREE")
        elif three:
            parts.append(line)
    s = b"".join(parts).upper().translate(TABLE, delete=b"\r")
    out = []
    frequencies(out, s, 1)
    frequencies(out, s, 2)
    for q in ("GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"):
        occurrences(out, s, q)
    sys.stdout.write("".join(out))


main()
