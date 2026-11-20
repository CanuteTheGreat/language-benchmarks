// hashmap - minstd keys, Dictionary<int,int>, C#.
int n = args.Length > 0 ? int.Parse(args[0]) : 10000;
var map = new Dictionary<int, int>();
long s1 = 42;
for (int i = 0; i < n; i++)
{
    s1 = s1 * 48271 % 2147483647;
    map[(int)s1] = i;
}
long s2 = 42;
long hits = 0, sum = 0;
for (int j = 0; j < 2 * n; j++)
{
    s2 = s2 * 48271 % 2147483647;
    if (map.TryGetValue((int)s2, out int v))
    {
        hits++;
        sum += v;
    }
}
Console.WriteLine($"{map.Count} {hits} {sum}");
