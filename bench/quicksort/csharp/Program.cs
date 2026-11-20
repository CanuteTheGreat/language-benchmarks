// quicksort - minstd data, hand-written quicksort, C#.
int n = args.Length > 0 ? int.Parse(args[0]) : 10000;
int[] a = new int[n];
long state = 42;
for (int i = 0; i < n; i++)
{
    state = state * 48271 % 2147483647;
    a[i] = (int)state;
}
Sorter.Sort(a, 0, n - 1);
for (int i = 1; i < n; i++)
    if (a[i - 1] > a[i]) return 1;
Console.WriteLine($"{a[0]} {a[n / 2]} {a[n - 1]}");
return 0;

static class Sorter
{
    static void Insertion(int[] a, int lo, int hi)
    {
        for (int i = lo + 1; i <= hi; i++)
        {
            int v = a[i];
            int j = i - 1;
            while (j >= lo && a[j] > v) { a[j + 1] = a[j]; j--; }
            a[j + 1] = v;
        }
    }

    public static void Sort(int[] a, int lo, int hi)
    {
        while (hi - lo >= 16)
        {
            int x = a[lo], y = a[(lo + hi) / 2], z = a[hi];
            int p;
            if (x < y) p = y < z ? y : (x < z ? z : x);
            else p = x < z ? x : (y < z ? z : y);
            int i = lo - 1, j = hi + 1;
            for (;;)
            {
                do i++; while (a[i] < p);
                do j--; while (a[j] > p);
                if (i >= j) break;
                (a[i], a[j]) = (a[j], a[i]);
            }
            if (j - lo < hi - j) { Sort(a, lo, j); lo = j + 1; }
            else { Sort(a, j + 1, hi); hi = j; }
        }
        Insertion(a, lo, hi);
    }
}
