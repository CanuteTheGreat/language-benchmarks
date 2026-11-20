// mandelbrot, C#
int n = args.Length > 0 ? int.Parse(args[0]) : 200;
int rb = (n + 7) / 8;
var img = new byte[rb * n];
for (int y = 0; y < n; y++) RowBits(n, y, img, y * rb);
using var stdout = new BufferedStream(Console.OpenStandardOutput(), 1 << 16);
stdout.Write(System.Text.Encoding.ASCII.GetBytes($"P4\n{n} {n}\n"));
stdout.Write(img);

static void RowBits(int n, int y, byte[] img, int off)
{
    double ci = 2.0 * y / n - 1.0;
    for (int x = 0; x < n; x++)
    {
        double cr = 2.0 * x / n - 1.5;
        double zr = 0, zi = 0, tr = 0, ti = 0;
        for (int i = 0; i < 50 && tr + ti <= 4.0; i++)
        {
            zi = 2.0 * zr * zi + ci;
            zr = tr - ti + cr;
            tr = zr * zr;
            ti = zi * zi;
        }
        if (tr + ti <= 4.0) img[off + (x >> 3)] |= (byte)(0x80 >> (x & 7));
    }
}
