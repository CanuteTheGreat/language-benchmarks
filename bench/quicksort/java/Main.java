// quicksort - minstd data, hand-written quicksort, Java.
public class Main {
    static void insertion(int[] a, int lo, int hi) {
        for (int i = lo + 1; i <= hi; i++) {
            int v = a[i];
            int j = i - 1;
            while (j >= lo && a[j] > v) { a[j + 1] = a[j]; j--; }
            a[j + 1] = v;
        }
    }

    static void sort(int[] a, int lo, int hi) {
        while (hi - lo >= 16) {
            int x = a[lo], y = a[(lo + hi) / 2], z = a[hi];
            int p;
            if (x < y) p = y < z ? y : (x < z ? z : x);
            else p = x < z ? x : (y < z ? z : y);
            int i = lo - 1, j = hi + 1;
            for (;;) {
                do i++; while (a[i] < p);
                do j--; while (a[j] > p);
                if (i >= j) break;
                int t = a[i]; a[i] = a[j]; a[j] = t;
            }
            if (j - lo < hi - j) { sort(a, lo, j); lo = j + 1; }
            else { sort(a, j + 1, hi); hi = j; }
        }
        insertion(a, lo, hi);
    }

    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 10000;
        int[] a = new int[n];
        long state = 42;
        for (int i = 0; i < n; i++) {
            state = state * 48271 % 2147483647;
            a[i] = (int) state;
        }
        sort(a, 0, n - 1);
        for (int i = 1; i < n; i++) {
            if (a[i - 1] > a[i]) System.exit(1);
        }
        System.out.println(a[0] + " " + a[n / 2] + " " + a[n - 1]);
    }
}
