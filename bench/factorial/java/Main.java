// factorial - N! with BigInteger, Java.
import java.math.BigInteger;

public class Main {
    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 100;
        BigInteger f = BigInteger.ONE;
        for (int i = 2; i <= n; i++) f = f.multiply(BigInteger.valueOf(i));
        String s = f.toString();
        long sum = 0;
        for (int i = 0; i < s.length(); i++) sum += s.charAt(i) - '0';
        System.out.println(s.length() + " " + sum);
    }
}
