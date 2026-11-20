// sieve - Sieve of Eratosthenes, Java
public class Main {
    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 1000000;
        boolean[] composite = new boolean[n + 1];
        for (long i = 2; i * i <= n; i++) {
            if (!composite[(int) i]) {
                for (long j = i * i; j <= n; j += i) composite[(int) j] = true;
            }
        }
        int count = 0;
        for (int i = 2; i <= n; i++) {
            if (!composite[i]) count++;
        }
        System.out.println(count);
    }
}
