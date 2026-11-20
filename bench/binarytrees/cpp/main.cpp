// binarytrees - C++
#include <cstdio>
#include <cstdlib>
#include <memory>

struct Node {
    std::unique_ptr<Node> left, right;
};

static std::unique_ptr<Node> make(int depth) {
    auto n = std::make_unique<Node>();
    if (depth > 0) { n->left = make(depth - 1); n->right = make(depth - 1); }
    return n;
}

static long check(const Node &n) {
    return n.left ? 1 + check(*n.left) + check(*n.right) : 1;
}

int main(int argc, char **argv) {
    int n = argc > 1 ? std::atoi(argv[1]) : 10;
    int min_depth = 4, max_depth = n > min_depth + 2 ? n : min_depth + 2;
    int stretch = max_depth + 1;

    std::printf("stretch tree of depth %d\t check: %ld\n", stretch, check(*make(stretch)));
    auto long_lived = make(max_depth);
    for (int d = min_depth; d <= max_depth; d += 2) {
        long iters = 1L << (max_depth - d + min_depth), sum = 0;
        for (long i = 0; i < iters; i++) sum += check(*make(d));
        std::printf("%ld\t trees of depth %d\t check: %ld\n", iters, d, sum);
    }
    std::printf("long lived tree of depth %d\t check: %ld\n", max_depth, check(*long_lived));
}
