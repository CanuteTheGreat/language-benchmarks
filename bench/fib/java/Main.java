// fib - naive recursive Fibonacci, Java
public class Main {
    static long fib(long n) {
        return n < 2 ? n : fib(n - 1) + fib(n - 2);
    }

    public static void main(String[] args) {
        long n = args.length > 0 ? Long.parseLong(args[0]) : 35;
        System.out.println(fib(n));
    }
}
