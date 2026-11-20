// regexredux - C# (System.Text.RegularExpressions)
using System.Text.RegularExpressions;

Regex Re(string p) => new Regex(p, RegexOptions.CultureInvariant | RegexOptions.Compiled);

string input = Console.In.ReadToEnd();
int len0 = input.Length;

string seq = Re(">.*\n|\n").Replace(input, "");
int len1 = seq.Length;

string[] variants =
{
    "agggtaaa|tttaccct",
    "[cgt]gggtaaa|tttaccc[acg]",
    "a[act]ggtaaa|tttacc[agt]t",
    "ag[act]gtaaa|tttac[agt]ct",
    "agg[act]taaa|ttta[agt]cct",
    "aggg[acg]aaa|ttt[cgt]ccct",
    "agggt[cgt]aa|tt[acg]accct",
    "agggta[cgt]a|t[acg]taccct",
    "agggtaa[cgt]|[acg]ttaccct",
};
foreach (var v in variants) Console.Out.Write($"{v} {Re(v).Count(seq)}\n");

(string, string)[] subs =
{
    ("tHa[Nt]", "<4>"),
    ("aND|caN|Ha[DS]|WaS", "<3>"),
    ("a[NSt]|BY", "<2>"),
    ("<[^>]*>", "|"),
    (@"\|[^|][^|]*\|", "-"),
};
foreach (var (pat, rep) in subs) seq = Re(pat).Replace(seq, rep);

Console.Out.Write($"\n{len0}\n{len1}\n{seq.Length}\n");
