# regexredux - Python (re)
import re
import sys


def rx(pattern):
    return re.compile(pattern)


def main():
    seq = sys.stdin.buffer.read().decode("latin-1")
    len0 = len(seq)

    seq = rx(">.*\n|\n").sub("", seq)
    len1 = len(seq)

    variants = [
        "agggtaaa|tttaccct",
        "[cgt]gggtaaa|tttaccc[acg]",
        "a[act]ggtaaa|tttacc[agt]t",
        "ag[act]gtaaa|tttac[agt]ct",
        "agg[act]taaa|ttta[agt]cct",
        "aggg[acg]aaa|ttt[cgt]ccct",
        "agggt[cgt]aa|tt[acg]accct",
        "agggta[cgt]a|t[acg]taccct",
        "agggtaa[cgt]|[acg]ttaccct",
    ]
    for v in variants:
        print(v, len(rx(v).findall(seq)))

    subs = [
        ("tHa[Nt]", "<4>"),
        ("aND|caN|Ha[DS]|WaS", "<3>"),
        ("a[NSt]|BY", "<2>"),
        ("<[^>]*>", "|"),
        (r"\|[^|][^|]*\|", "-"),
    ]
    for pat, rep in subs:
        seq = rx(pat).sub(rep, seq)

    print()
    print(len0)
    print(len1)
    print(len(seq))


main()
