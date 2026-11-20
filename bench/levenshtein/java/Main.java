// levenshtein - Java
public class Main {
    static long state = 42;

    static int next() {
        state = (state * 48271) % 2147483647L;
        return (int) state;
    }

    static char[] makeString(int len) {
        char[] s = new char[len];
        for (int i = 0; i < len; i++) s[i] = "ACGT".charAt(next() % 4);
        return s;
    }

    public static void main(String[] args) {
        int len = args.length > 0 ? Integer.parseInt(args[0]) : 300;
        char[] s = makeString(len);
        char[] t = makeString(len);

        int[] prev = new int[len + 1];
        int[] cur = new int[len + 1];
        for (int j = 0; j <= len; j++) prev[j] = j;
        for (int i = 1; i <= len; i++) {
            cur[0] = i;
            for (int j = 1; j <= len; j++) {
                int sub = prev[j - 1] + (s[i - 1] != t[j - 1] ? 1 : 0);
                cur[j] = Math.min(sub, Math.min(prev[j] + 1, cur[j - 1] + 1));
            }
            int[] tmp = prev; prev = cur; cur = tmp;
        }
        System.out.println(prev[len]);
    }
}
