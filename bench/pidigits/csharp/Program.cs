// pidigits - Benchmarks Game spigot with System.Numerics.BigInteger, C#.
using System.Numerics;
using System.Text;

int n = args.Length > 0 ? int.Parse(args[0]) : 30;
BigInteger numer = 1, accum = 0, denom = 1;
var sb = new StringBuilder();
int i = 0;
long k = 0;
while (i < n)
{
    k++;
    long y2 = k * 2 + 1;
    accum = (accum + numer * 2) * y2;
    numer *= k;
    denom *= y2;
    if (numer > accum) continue;
    int d = (int)((numer * 3 + accum) / denom);
    if (d != (int)((numer * 4 + accum) / denom)) continue;
    sb.Append((char)('0' + d));
    i++;
    if (i % 10 == 0) sb.Append("\t:").Append(i).Append('\n');
    accum = (accum - denom * d) * 10;
    numer *= 10;
}
if (n % 10 != 0) sb.Append(' ', 10 - n % 10).Append("\t:").Append(n).Append('\n');
Console.Out.Write(sb.ToString());
