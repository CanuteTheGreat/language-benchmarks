// sortstd - minstd data, Array.Sort, C#.
int n = args.Length > 0 ? int.Parse(args[0]) : 10000;
int[] a = new int[n];
long state = 42;
for (int i = 0; i < n; i++)
{
    state = state * 48271 % 2147483647;
    a[i] = (int)state;
}
Array.Sort(a);
for (int i = 1; i < n; i++)
    if (a[i - 1] > a[i]) return 1;
Console.WriteLine($"{a[0]} {a[n / 2]} {a[n - 1]}");
return 0;
