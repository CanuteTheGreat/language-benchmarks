// binarytrees - Java
public class Main {
    static final class Node {
        final Node left, right;
        Node(Node l, Node r) { left = l; right = r; }
    }

    static Node make(int depth) {
        return depth == 0 ? new Node(null, null) : new Node(make(depth - 1), make(depth - 1));
    }

    static long check(Node n) {
        return n.left == null ? 1 : 1 + check(n.left) + check(n.right);
    }

    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 10;
        int minDepth = 4, maxDepth = Math.max(n, minDepth + 2);
        int stretch = maxDepth + 1;
        StringBuilder out = new StringBuilder();

        out.append("stretch tree of depth ").append(stretch).append("\t check: ").append(check(make(stretch))).append('\n');
        Node longLived = make(maxDepth);
        for (int d = minDepth; d <= maxDepth; d += 2) {
            long iters = 1L << (maxDepth - d + minDepth), sum = 0;
            for (long i = 0; i < iters; i++) sum += check(make(d));
            out.append(iters).append("\t trees of depth ").append(d).append("\t check: ").append(sum).append('\n');
        }
        out.append("long lived tree of depth ").append(maxDepth).append("\t check: ").append(check(longLived)).append('\n');
        System.out.print(out);
    }
}
