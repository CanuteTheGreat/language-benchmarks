// pidigits - Benchmarks Game spigot with BigInteger, Java.
import java.math.BigInteger;

public class Main {
    static BigInteger numer = BigInteger.ONE, accum = BigInteger.ZERO, denom = BigInteger.ONE;

    static int extractDigit(long nth) {
        return numer.multiply(BigInteger.valueOf(nth)).add(accum).divide(denom).intValue();
    }

    static void nextTerm(long k) {
        BigInteger y2 = BigInteger.valueOf(k * 2 + 1);
        accum = accum.add(numer.shiftLeft(1)).multiply(y2);
        numer = numer.multiply(BigInteger.valueOf(k));
        denom = denom.multiply(y2);
    }

    static void eliminateDigit(int d) {
        accum = accum.subtract(denom.multiply(BigInteger.valueOf(d))).multiply(BigInteger.TEN);
        numer = numer.multiply(BigInteger.TEN);
    }

    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 30;
        StringBuilder out = new StringBuilder();
        int i = 0;
        long k = 0;
        while (i < n) {
            k++;
            nextTerm(k);
            if (numer.compareTo(accum) > 0) continue;
            int d = extractDigit(3);
            if (d != extractDigit(4)) continue;
            out.append((char) ('0' + d));
            i++;
            if (i % 10 == 0) out.append("\t:").append(i).append('\n');
            eliminateDigit(d);
        }
        if (n % 10 != 0) out.append(" ".repeat(10 - n % 10)).append("\t:").append(n).append('\n');
        System.out.print(out);
    }
}
