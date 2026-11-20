// sortstd - minstd data, Arrays.sort(int[]), Java.
import java.util.Arrays;

public class Main {
    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 10000;
        int[] a = new int[n];
        long state = 42;
        for (int i = 0; i < n; i++) {
            state = state * 48271 % 2147483647;
            a[i] = (int) state;
        }
        Arrays.sort(a);
        for (int i = 1; i < n; i++) {
            if (a[i - 1] > a[i]) System.exit(1);
        }
        System.out.println(a[0] + " " + a[n / 2] + " " + a[n - 1]);
    }
}
