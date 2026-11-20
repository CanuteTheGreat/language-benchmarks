// sieve - Sieve of Eratosthenes, C#
int n = args.Length > 0 ? int.Parse(args[0]) : 1000000;
var composite = new bool[n + 1];
for (long i = 2; i * i <= n; i++)
{
    if (!composite[i])
    {
        for (long j = i * i; j <= n; j += i) composite[j] = true;
    }
}
int count = 0;
for (int i = 2; i <= n; i++)
{
    if (!composite[i]) count++;
}
Console.WriteLine(count);
