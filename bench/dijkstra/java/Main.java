// dijkstra - minstd graph, ArrayList adjacency, java.util.PriorityQueue, Java.
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.PriorityQueue;

public class Main {
    record Edge(int to, int w) {}

    public static void main(String[] args) {
        int nv = args.length > 1 ? Integer.parseInt(args[0]) : 1000;
        int ne = args.length > 1 ? Integer.parseInt(args[1]) : 5000;
        List<List<Edge>> adj = new ArrayList<>(nv);
        for (int i = 0; i < nv; i++) adj.add(new ArrayList<>());
        long g = 42;
        for (int e = 0; e < ne; e++) {
            g = g * 48271 % 2147483647; int u = (int) (g % nv);
            g = g * 48271 % 2147483647; int v = (int) (g % nv);
            g = g * 48271 % 2147483647; int w = (int) (g % 100 + 1);
            adj.get(u).add(new Edge(v, w));
        }
        long[] dist = new long[nv];
        Arrays.fill(dist, Long.MAX_VALUE);
        PriorityQueue<long[]> pq = new PriorityQueue<>((a, b) -> Long.compare(a[0], b[0]));
        dist[0] = 0;
        pq.add(new long[] {0, 0});
        while (!pq.isEmpty()) {
            long[] it = pq.poll();
            int u = (int) it[1];
            if (it[0] > dist[u]) continue;
            for (Edge e : adj.get(u)) {
                long nd = it[0] + e.w();
                if (nd < dist[e.to()]) {
                    dist[e.to()] = nd;
                    pq.add(new long[] {nd, e.to()});
                }
            }
        }
        long reached = 0, sum = 0, max = 0;
        for (long d : dist) {
            if (d != Long.MAX_VALUE) {
                reached++;
                sum += d;
                max = Math.max(max, d);
            }
        }
        System.out.println(reached + " " + sum + " " + max);
    }
}
