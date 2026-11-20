// revcomp - C#
var comp = new byte[256];
for (int i = 0; i < 256; i++) comp[i] = (byte)i;
const string from = "ACGTUMRWSYKVHDBN", to = "TGCAAKYWSRMBDHVN";
for (int i = 0; i < from.Length; i++)
{
    comp[from[i]] = (byte)to[i];
    comp[from[i] | 0x20] = (byte)to[i];
}

// Write the reverse complement of seq[0..n) in lines of 60.
void Emit(Stream o, byte[] seq, int n)
{
    var line = new byte[61];
    while (n > 0)
    {
        int m = Math.Min(n, 60);
        for (int j = 0; j < m; j++) line[j] = comp[seq[--n]];
        line[m] = (byte)'\n';
        o.Write(line, 0, m + 1);
    }
}

using var stdout = new BufferedStream(Console.OpenStandardOutput(), 1 << 16);
using var reader = new StreamReader(Console.OpenStandardInput(), System.Text.Encoding.Latin1, false, 1 << 16);
var seq = new byte[1 << 16];
int len = 0;
string line;
while ((line = reader.ReadLine()) != null)
{
    if (line.StartsWith('>'))
    {
        Emit(stdout, seq, len);
        len = 0;
        stdout.Write(System.Text.Encoding.Latin1.GetBytes(line + "\n"));
    }
    else
    {
        if (len + line.Length > seq.Length) Array.Resize(ref seq, Math.Max(seq.Length * 2, len + line.Length));
        foreach (char c in line) seq[len++] = (byte)c;
    }
}
Emit(stdout, seq, len);
stdout.Flush();
