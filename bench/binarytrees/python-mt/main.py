# binarytrees - Python, multiprocessing
import os
import sys
from multiprocessing import Pool


def make(depth):
    if depth == 0:
        return (None, None)
    return (make(depth - 1), make(depth - 1))


def check(node):
    left, right = node
    if left is None:
        return 1
    return 1 + check(left) + check(right)


def work(args):
    depth, count = args
    total = 0
    for _ in range(count):
        total += check(make(depth))
    return total


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    min_depth = 4
    max_depth = max(n, min_depth + 2)
    stretch = max_depth + 1
    ncpu = len(os.sched_getaffinity(0))
    out = [f"stretch tree of depth {stretch}\t check: {check(make(stretch))}\n"]
    long_lived = make(max_depth)
    with Pool(ncpu) as pool:
        for d in range(min_depth, max_depth + 1, 2):
            iters = 1 << (max_depth - d + min_depth)
            chunks = min(iters, ncpu * 4)
            per, extra = divmod(iters, chunks)
            jobs = [(d, per + (1 if i < extra else 0)) for i in range(chunks)]
            total = sum(pool.map(work, jobs))
            out.append(f"{iters}\t trees of depth {d}\t check: {total}\n")
    out.append(f"long lived tree of depth {max_depth}\t check: {check(long_lived)}\n")
    sys.stdout.write("".join(out))


if __name__ == "__main__":
    main()
