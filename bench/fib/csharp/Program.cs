// fib - naive recursive Fibonacci, C#
static long Fib(long n) => n < 2 ? n : Fib(n - 1) + Fib(n - 2);

long n = args.Length > 0 ? long.Parse(args[0]) : 35;
Console.WriteLine(Fib(n));
