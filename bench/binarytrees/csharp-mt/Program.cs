// binarytrees - C#, Parallel.For
using System.Text;

int n = args.Length > 0 ? int.Parse(args[0]) : 10;
int minDepth = 4, maxDepth = Math.Max(n, minDepth + 2);
int stretch = maxDepth + 1;
var sb = new StringBuilder();

sb.Append($"stretch tree of depth {stretch}\t check: {Node.Make(stretch).Check()}\n");
var longLived = Node.Make(maxDepth);
for (int d = minDepth; d <= maxDepth; d += 2)
{
    long iters = 1L << (maxDepth - d + minDepth), sum = 0;
    int depth = d;
    Parallel.For(0L, iters, () => 0L,
        (i, _, local) => local + Node.Make(depth).Check(),
        local => Interlocked.Add(ref sum, local));
    sb.Append($"{iters}\t trees of depth {d}\t check: {sum}\n");
}
sb.Append($"long lived tree of depth {maxDepth}\t check: {longLived.Check()}\n");
Console.Out.Write(sb.ToString());

class Node
{
    public readonly Node? Left, Right;
    public Node(Node? l, Node? r) { Left = l; Right = r; }

    public static Node Make(int depth) =>
        depth == 0 ? new Node(null, null) : new Node(Make(depth - 1), Make(depth - 1));

    public long Check() => Left is null ? 1 : 1 + Left.Check() + Right!.Check();
}
