// levenshtein - C#
int len = args.Length > 0 ? int.Parse(args[0]) : 300;
long state = 42;

int Next()
{
    state = state * 48271 % 2147483647;
    return (int)state;
}

char[] MakeString(int n)
{
    var s = new char[n];
    for (int i = 0; i < n; i++) s[i] = "ACGT"[Next() % 4];
    return s;
}

var a = MakeString(len);
var b = MakeString(len);
var prev = new int[len + 1];
var cur = new int[len + 1];
for (int j = 0; j <= len; j++) prev[j] = j;
for (int i = 1; i <= len; i++)
{
    cur[0] = i;
    for (int j = 1; j <= len; j++)
    {
        int sub = prev[j - 1] + (a[i - 1] != b[j - 1] ? 1 : 0);
        cur[j] = Math.Min(sub, Math.Min(prev[j] + 1, cur[j - 1] + 1));
    }
    (prev, cur) = (cur, prev);
}
Console.WriteLine(prev[len]);
