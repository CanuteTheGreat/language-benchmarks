// fannkuchredux, Java
public class Main {
    static final long[] fact = new long[21];

    // Process permutations with index in [start, end); returns {checksum, max flips}.
    static long[] work(int n, long start, long end) {
        int[] p = new int[n], pp = new int[n], q = new int[n], count = new int[n];
        long idx = start;
        for (int i = 0; i < n; i++) p[i] = i;
        for (int i = n - 1; i > 0; i--) {
            int d = (int) (idx / fact[i]);
            idx %= fact[i];
            count[i] = d;
            System.arraycopy(p, 0, pp, 0, n);
            for (int j = 0; j <= i; j++) p[j] = (j + d <= i) ? pp[j + d] : pp[j + d - i - 1];
        }
        long sum = 0;
        int maxflips = 0;
        for (long k = start; k < end; k++) {
            if (k > start) {
                int first = p[1];
                p[1] = p[0];
                p[0] = first;
                int i = 1;
                while (++count[i] > i) {
                    count[i++] = 0;
                    int next = p[0] = p[1];
                    for (int j = 1; j < i; j++) p[j] = p[j + 1];
                    p[i] = first;
                    first = next;
                }
            }
            System.arraycopy(p, 0, q, 0, n);
            int flips = 0;
            while (q[0] != 0) {
                for (int i = 0, j = q[0]; i < j; i++, j--) {
                    int t = q[i];
                    q[i] = q[j];
                    q[j] = t;
                }
                flips++;
            }
            if (flips > maxflips) maxflips = flips;
            sum += (k % 2 == 0) ? flips : -flips;
        }
        return new long[] {sum, maxflips};
    }

    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 7;
        fact[0] = 1;
        for (int i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
        long[] r = work(n, 0, fact[n]);
        System.out.println(r[0] + "\nPfannkuchen(" + n + ") = " + r[1]);
    }
}
