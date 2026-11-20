// spectralnorm benchmark, C# (Parallel.For)
using System.Globalization;

static double EvalA(int i, int j) => 1.0 / ((i + j) * (i + j + 1) / 2 + i + 1);

static void MulAv(double[] v, double[] result)
{
    Parallel.For(0, result.Length, i =>
    {
        double sum = 0;
        for (int j = 0; j < v.Length; j++) sum += EvalA(i, j) * v[j];
        result[i] = sum;
    });
}

static void MulAtv(double[] v, double[] result)
{
    Parallel.For(0, result.Length, i =>
    {
        double sum = 0;
        for (int j = 0; j < v.Length; j++) sum += EvalA(j, i) * v[j];
        result[i] = sum;
    });
}

static void MulAtAv(double[] v, double[] result, double[] tmp)
{
    MulAv(v, tmp);
    MulAtv(tmp, result);
}

int n = args.Length > 0 ? int.Parse(args[0]) : 100;
var u = new double[n];
var v = new double[n];
var tmp = new double[n];
Array.Fill(u, 1.0);
for (int i = 0; i < 10; i++)
{
    MulAtAv(u, v, tmp);
    MulAtAv(v, u, tmp);
}
double vbv = 0, vv = 0;
for (int i = 0; i < n; i++)
{
    vbv += u[i] * v[i];
    vv += v[i] * v[i];
}
Console.WriteLine(Math.Sqrt(vbv / vv).ToString("F9", CultureInfo.InvariantCulture));
