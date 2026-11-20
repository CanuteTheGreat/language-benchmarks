// regexredux - Java (java.util.regex)
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.regex.*;

public class Main {
    static Pattern re(String p) {
        return Pattern.compile(p);
    }

    public static void main(String[] args) throws IOException {
        String input = new String(System.in.readAllBytes(), StandardCharsets.ISO_8859_1);
        int len0 = input.length();

        String seq = re(">.*\n|\n").matcher(input).replaceAll("");
        int len1 = seq.length();

        String[] variants = {
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
        StringBuilder out = new StringBuilder();
        for (String v : variants) {
            Matcher m = re(v).matcher(seq);
            int n = 0;
            while (m.find()) n++;
            out.append(v).append(' ').append(n).append('\n');
        }

        String[][] subs = {
            {"tHa[Nt]", "<4>"},
            {"aND|caN|Ha[DS]|WaS", "<3>"},
            {"a[NSt]|BY", "<2>"},
            {"<[^>]*>", "|"},
            {"\\|[^|][^|]*\\|", "-"},
        };
        for (String[] s : subs) {
            seq = re(s[0]).matcher(seq).replaceAll(Matcher.quoteReplacement(s[1]));
        }
        out.append('\n').append(len0).append('\n').append(len1).append('\n').append(seq.length()).append('\n');
        System.out.print(out);
    }
}
