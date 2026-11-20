// fasta - C#
const int LineLen = 60;
const int IM = 139968, IA = 3877, IC = 29573;
int last = 42;

double Rnd(double max)
{
    last = (last * IA + IC) % IM;
    return max * last / IM;
}

const string Alu =
    "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG" +
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" +
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT" +
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" +
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG" +
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" +
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

int n = args.Length > 0 ? int.Parse(args[0]) : 1000;
using var stdout = Console.OpenStandardOutput();
using var output = new BufferedStream(stdout, 1 << 16);
var line = new byte[LineLen + 1];

void Header(string s)
{
    foreach (char ch in s) output.WriteByte((byte)ch);
    output.WriteByte((byte)'\n');
}

void RepeatFasta(string s, int count)
{
    int pos = 0;
    while (count > 0)
    {
        int m = Math.Min(count, LineLen);
        for (int i = 0; i < m; i++)
        {
            line[i] = (byte)s[pos++];
            if (pos == s.Length) pos = 0;
        }
        line[m] = (byte)'\n';
        output.Write(line, 0, m + 1);
        count -= m;
    }
}

void RandomFasta((char c, double p)[] genes, int count)
{
    var cum = new double[genes.Length];
    double acc = 0;
    for (int i = 0; i < genes.Length; i++) { acc += genes[i].p; cum[i] = acc; }
    while (count > 0)
    {
        int m = Math.Min(count, LineLen);
        for (int i = 0; i < m; i++)
        {
            double r = Rnd(1.0);
            int k = 0;
            while (k < genes.Length - 1 && r >= cum[k]) k++;
            line[i] = (byte)genes[k].c;
        }
        line[m] = (byte)'\n';
        output.Write(line, 0, m + 1);
        count -= m;
    }
}

(char, double)[] iub =
{
    ('a', 0.27), ('c', 0.12), ('g', 0.12), ('t', 0.27),
    ('B', 0.02), ('D', 0.02), ('H', 0.02), ('K', 0.02),
    ('M', 0.02), ('N', 0.02), ('R', 0.02), ('S', 0.02),
    ('V', 0.02), ('W', 0.02), ('Y', 0.02),
};
(char, double)[] homoSapiens =
{
    ('a', 0.3029549426680),
    ('c', 0.1979883004921),
    ('g', 0.1975473066391),
    ('t', 0.3015094502008),
};

Header(">ONE Homo sapiens alu");
RepeatFasta(Alu, n * 2);
Header(">TWO IUB ambiguity codes");
RandomFasta(iub, n * 3);
Header(">THREE Homo sapiens frequency");
RandomFasta(homoSapiens, n * 5);
output.Flush();
