// knucleotide - C#
using System.Globalization;
using System.Text;

const string Letters = "ACGT";

Dictionary<ulong, int> Count(List<byte> s, int k)
{
    var m = new Dictionary<ulong, int>();
    ulong mask = (1UL << (2 * k)) - 1, key = 0;
    for (int i = 0; i < s.Count; i++)
    {
        key = ((key << 2) | s[i]) & mask;
        if (i + 1 >= k)
        {
            m.TryGetValue(key, out int c);
            m[key] = c + 1;
        }
    }
    return m;
}

void Frequencies(StringBuilder o, List<byte> s, int k)
{
    var v = Count(s, k).ToList();
    v.Sort((a, b) => a.Value != b.Value ? b.Value.CompareTo(a.Value) : a.Key.CompareTo(b.Key));
    double total = s.Count - k + 1;
    foreach (var (key, cnt) in v)
    {
        var name = new char[k];
        for (int j = 0; j < k; j++) name[j] = Letters[(int)((key >> (2 * (k - 1 - j))) & 3)];
        o.Append(name).Append(' ').Append((100.0 * cnt / total).ToString("F3", CultureInfo.InvariantCulture)).Append('\n');
    }
    o.Append('\n');
}

void Occurrences(StringBuilder o, List<byte> s, string seq)
{
    ulong key = 0;
    foreach (char c in seq) key = (key << 2) | (ulong)Letters.IndexOf(c);
    Count(s, seq.Length).TryGetValue(key, out int cnt);
    o.Append(cnt).Append('\t').Append(seq).Append('\n');
}

var codes = new List<byte>();
bool three = false;
string line;
while ((line = Console.In.ReadLine()) != null)
{
    if (line.StartsWith('>'))
        three = line.StartsWith(">THREE", StringComparison.Ordinal);
    else if (three)
        foreach (char ch in line)
        {
            int c = Letters.IndexOf(char.ToUpperInvariant(ch));
            if (c >= 0) codes.Add((byte)c);
        }
}
var o = new StringBuilder();
Frequencies(o, codes, 1);
Frequencies(o, codes, 2);
foreach (var q in new[] { "GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT" }) Occurrences(o, codes, q);
Console.Out.Write(o.ToString());
