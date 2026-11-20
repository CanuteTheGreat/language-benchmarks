// collatz - longest Collatz sequence below N, Java
public class Main {
    public static void main(String[] args) {
        long limit = args.length > 0 ? Long.parseLong(args[0]) : 1000000;
        long best = 1;
        int bestSteps = 0;
        for (long s = 1; s < limit; s++) {
            long n = s;
            int steps = 0;
            while (n != 1) {
                n = (n & 1) == 1 ? 3 * n + 1 : n / 2;
                steps++;
            }
            if (steps > bestSteps) {
                bestSteps = steps;
                best = s;
            }
        }
        System.out.println(best + " " + bestSteps);
    }
}
