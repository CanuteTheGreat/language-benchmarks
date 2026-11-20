# revcomp - Python
import sys

TABLE = bytes.maketrans(b"ACGTUMRWSYKVHDBNacgtumrwsykvhdbn", b"TGCAAKYWSRMBDHVN" * 2)


def emit(out, parts):
    seq = b"".join(parts).translate(TABLE)[::-1]
    if seq:
        out.write(b"\n".join(seq[i:i + 60] for i in range(0, len(seq), 60)) + b"\n")


def main():
    out = sys.stdout.buffer
    parts = []
    for line in sys.stdin.buffer:
        if line.startswith(b">"):
            emit(out, parts)
            parts = []
            out.write(line)
        else:
            parts.append(line.rstrip(b"\r\n"))
    emit(out, parts)
    out.flush()


main()
