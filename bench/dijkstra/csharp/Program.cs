// dijkstra - minstd graph, List<(int,int)> adjacency, PriorityQueue<int,long>, C#.
int nv = args.Length > 1 ? int.Parse(args[0]) : 1000;
int ne = args.Length > 1 ? int.Parse(args[1]) : 5000;
var adj = new List<(int To, int W)>[nv];
for (int i = 0; i < nv; i++) adj[i] = new List<(int, int)>();
long g = 42;
for (int e = 0; e < ne; e++)
{
    g = g * 48271 % 2147483647; int u = (int)(g % nv);
    g = g * 48271 % 2147483647; int v = (int)(g % nv);
    g = g * 48271 % 2147483647; int w = (int)(g % 100 + 1);
    adj[u].Add((v, w));
}
var dist = new long[nv];
Array.Fill(dist, long.MaxValue);
var pq = new PriorityQueue<int, long>();
dist[0] = 0;
pq.Enqueue(0, 0);
while (pq.TryDequeue(out int x, out long d))
{
    if (d > dist[x]) continue;
    foreach (var (to, w) in adj[x])
    {
        long nd = d + w;
        if (nd < dist[to])
        {
            dist[to] = nd;
            pq.Enqueue(to, nd);
        }
    }
}
long reached = 0, sum = 0, max = 0;
foreach (long d in dist)
{
    if (d != long.MaxValue)
    {
        reached++;
        sum += d;
        max = Math.Max(max, d);
    }
}
Console.WriteLine($"{reached} {sum} {max}");
