// knucleotide - Java
import java.io.*;
import java.util.*;

public class Main {
    static final String LETTERS = "ACGT";

    static Map<Long, Integer> count(byte[] s, int n, int k) {
        Map<Long, Integer> m = new HashMap<>();
        long mask = (1L << (2 * k)) - 1, key = 0;
        for (int i = 0; i < n; i++) {
            key = ((key << 2) | s[i]) & mask;
            if (i + 1 >= k) m.merge(key, 1, Integer::sum);
        }
        return m;
    }

    static void frequencies(StringBuilder out, byte[] s, int n, int k) {
        List<Map.Entry<Long, Integer>> v = new ArrayList<>(count(s, n, k).entrySet());
        v.sort((a, b) -> !a.getValue().equals(b.getValue())
                ? Integer.compare(b.getValue(), a.getValue())
                : Long.compare(a.getKey(), b.getKey()));
        double total = n - k + 1;
        for (Map.Entry<Long, Integer> e : v) {
            char[] name = new char[k];
            for (int j = 0; j < k; j++) name[j] = LETTERS.charAt((int) ((e.getKey() >> (2 * (k - 1 - j))) & 3));
            out.append(name).append(' ')
               .append(String.format(Locale.ROOT, "%.3f", 100.0 * e.getValue() / total)).append('\n');
        }
        out.append('\n');
    }

    static void occurrences(StringBuilder out, byte[] s, int n, String seq) {
        long key = 0;
        for (char c : seq.toCharArray()) key = (key << 2) | LETTERS.indexOf(c);
        Integer c = count(s, n, seq.length()).get(key);
        out.append(c == null ? 0 : c).append('\t').append(seq).append('\n');
    }

    public static void main(String[] args) throws IOException {
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
        byte[] s = new byte[1 << 20];
        int n = 0;
        String line;
        boolean three = false;
        while ((line = in.readLine()) != null) {
            if (line.startsWith(">")) {
                three = line.startsWith(">THREE");
            } else if (three) {
                if (n + line.length() > s.length) s = Arrays.copyOf(s, Math.max(s.length * 2, n + line.length()));
                for (int i = 0; i < line.length(); i++) {
                    int c = LETTERS.indexOf(Character.toUpperCase(line.charAt(i)));
                    if (c >= 0) s[n++] = (byte) c;
                }
            }
        }
        StringBuilder out = new StringBuilder();
        frequencies(out, s, n, 1);
        frequencies(out, s, n, 2);
        for (String q : new String[] {"GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"}) {
            occurrences(out, s, n, q);
        }
        System.out.print(out);
        System.out.flush();
    }
}
