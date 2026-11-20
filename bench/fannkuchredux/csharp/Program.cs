// fannkuchredux, C#
int n = args.Length > 0 ? int.Parse(args[0]) : 7;
var fact = new long[n + 1];
fact[0] = 1;
for (int i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
var (chk, mx) = Fannkuch.Work(n, fact, 0, fact[n]);
Console.WriteLine($"{chk}\nPfannkuchen({n}) = {mx}");

static class Fannkuch
{
    // Process permutations with index in [start, end); returns (checksum, max flips).
    public static (long, int) Work(int n, long[] fact, long start, long end)
    {
        var p = new int[n];
        var pp = new int[n];
        var q = new int[n];
        var count = new int[n];
        long idx = start;
        for (int i = 0; i < n; i++) p[i] = i;
        for (int i = n - 1; i > 0; i--)
        {
            int d = (int)(idx / fact[i]);
            idx %= fact[i];
            count[i] = d;
            Array.Copy(p, pp, n);
            for (int j = 0; j <= i; j++) p[j] = (j + d <= i) ? pp[j + d] : pp[j + d - i - 1];
        }
        long sum = 0;
        int maxflips = 0;
        for (long k = start; k < end; k++)
        {
            if (k > start)
            {
                int first = p[1];
                p[1] = p[0];
                p[0] = first;
                int i = 1;
                while (++count[i] > i)
                {
                    count[i++] = 0;
                    int next = p[0] = p[1];
                    for (int j = 1; j < i; j++) p[j] = p[j + 1];
                    p[i] = first;
                    first = next;
                }
            }
            Array.Copy(p, q, n);
            int flips = 0;
            while (q[0] != 0)
            {
                Array.Reverse(q, 0, q[0] + 1);
                flips++;
            }
            if (flips > maxflips) maxflips = flips;
            sum += (k % 2 == 0) ? flips : -flips;
        }
        return (sum, maxflips);
    }
}
