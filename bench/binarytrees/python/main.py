# binarytrees - Python
import sys


def make(depth):
    if depth == 0:
        return (None, None)
    return (make(depth - 1), make(depth - 1))


def check(node):
    left, right = node
    if left is None:
        return 1
    return 1 + check(left) + check(right)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    min_depth = 4
    max_depth = max(n, min_depth + 2)
    stretch = max_depth + 1
    out = [f"stretch tree of depth {stretch}\t check: {check(make(stretch))}\n"]
    long_lived = make(max_depth)
    for d in range(min_depth, max_depth + 1, 2):
        iters = 1 << (max_depth - d + min_depth)
        total = 0
        for _ in range(iters):
            total += check(make(d))
        out.append(f"{iters}\t trees of depth {d}\t check: {total}\n")
    out.append(f"long lived tree of depth {max_depth}\t check: {check(long_lived)}\n")
    sys.stdout.write("".join(out))


main()
