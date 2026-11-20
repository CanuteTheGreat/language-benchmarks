# fasta - Python
import sys

LINE = 60
IM, IA, IC = 139968, 3877, 29573
last = 42

ALU = (
    "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"
)

IUB = [
    ("a", 0.27), ("c", 0.12), ("g", 0.12), ("t", 0.27),
    ("B", 0.02), ("D", 0.02), ("H", 0.02), ("K", 0.02),
    ("M", 0.02), ("N", 0.02), ("R", 0.02), ("S", 0.02),
    ("V", 0.02), ("W", 0.02), ("Y", 0.02),
]
HOMO_SAPIENS = [
    ("a", 0.3029549426680),
    ("c", 0.1979883004921),
    ("g", 0.1975473066391),
    ("t", 0.3015094502008),
]


def repeat_fasta(out, s, n):
    # the sequence repeated endlessly, cut into lines of LINE characters
    reps = (n + len(s) - 1) // len(s) + 1
    text = s * reps
    pos = 0
    while n > 0:
        m = min(n, LINE)
        out.append(text[pos:pos + m] + "\n")
        pos = (pos + m) % len(s)
        n -= m


def random_fasta(out, genes, n):
    global last
    cum = []
    acc = 0.0
    for c, p in genes:
        acc += p
        cum.append((c, acc))
    top = len(cum) - 1
    while n > 0:
        m = min(n, LINE)
        chars = []
        for _ in range(m):
            last = (last * IA + IC) % IM
            r = last / IM
            k = 0
            while k < top and r >= cum[k][1]:
                k += 1
            chars.append(cum[k][0])
        chars.append("\n")
        out.append("".join(chars))
        n -= m


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    out = [">ONE Homo sapiens alu\n"]
    repeat_fasta(out, ALU, n * 2)
    out.append(">TWO IUB ambiguity codes\n")
    random_fasta(out, IUB, n * 3)
    out.append(">THREE Homo sapiens frequency\n")
    random_fasta(out, HOMO_SAPIENS, n * 5)
    sys.stdout.write("".join(out))


main()
