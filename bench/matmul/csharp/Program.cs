// matmul - naive matrix multiply (i,k,j), C#
int n = args.Length > 0 ? int.Parse(args[0]) : 400;
var a = new double[n, n];
var b = new double[n, n];
var c = new double[n, n];
for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
    {
        a[i, j] = (i + j) % 10;
        b[i, j] = (i * j) % 10;
    }
for (int i = 0; i < n; i++)
    for (int k = 0; k < n; k++)
        for (int j = 0; j < n; j++) c[i, j] += a[i, k] * b[k, j];
double sum = 0;
foreach (double v in c) sum += v;
Console.WriteLine((long)sum);
