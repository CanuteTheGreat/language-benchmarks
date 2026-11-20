// factorial - N! with System.Numerics.BigInteger, C#.
using System.Numerics;

int n = args.Length > 0 ? int.Parse(args[0]) : 100;
BigInteger f = BigInteger.One;
for (int i = 2; i <= n; i++) f *= i;
string s = f.ToString();
long sum = 0;
foreach (char c in s) sum += c - '0';
Console.WriteLine($"{s.Length} {sum}");
