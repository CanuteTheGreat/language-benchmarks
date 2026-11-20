// fasta - Java
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class Main {
    static final int LINE = 60;
    static final int IM = 139968, IA = 3877, IC = 29573;
    static int last = 42;

    static double rnd(double max) {
        last = (last * IA + IC) % IM;
        return max * last / IM;
    }

    record AminoAcid(char c, double p) {}

    static final String ALU =
        "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
        + "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
        + "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
        + "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
        + "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
        + "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
        + "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

    static void repeatFasta(OutputStream out, String s, int n) throws IOException {
        byte[] line = new byte[LINE + 1];
        int pos = 0;
        while (n > 0) {
            int m = Math.min(n, LINE);
            for (int i = 0; i < m; i++) {
                line[i] = (byte) s.charAt(pos++);
                if (pos == s.length()) pos = 0;
            }
            line[m] = '\n';
            out.write(line, 0, m + 1);
            n -= m;
        }
    }

    static void randomFasta(OutputStream out, AminoAcid[] genes, int n) throws IOException {
        double[] cum = new double[genes.length];
        double acc = 0;
        for (int i = 0; i < genes.length; i++) {
            acc += genes[i].p();
            cum[i] = acc;
        }
        byte[] line = new byte[LINE + 1];
        while (n > 0) {
            int m = Math.min(n, LINE);
            for (int i = 0; i < m; i++) {
                double r = rnd(1.0);
                int k = 0;
                while (k < genes.length - 1 && r >= cum[k]) k++;
                line[i] = (byte) genes[k].c();
            }
            line[m] = '\n';
            out.write(line, 0, m + 1);
            n -= m;
        }
    }

    public static void main(String[] args) throws IOException {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 1000;
        AminoAcid[] iub = {
            new AminoAcid('a', 0.27), new AminoAcid('c', 0.12), new AminoAcid('g', 0.12), new AminoAcid('t', 0.27),
            new AminoAcid('B', 0.02), new AminoAcid('D', 0.02), new AminoAcid('H', 0.02), new AminoAcid('K', 0.02),
            new AminoAcid('M', 0.02), new AminoAcid('N', 0.02), new AminoAcid('R', 0.02), new AminoAcid('S', 0.02),
            new AminoAcid('V', 0.02), new AminoAcid('W', 0.02), new AminoAcid('Y', 0.02),
        };
        AminoAcid[] homoSapiens = {
            new AminoAcid('a', 0.3029549426680),
            new AminoAcid('c', 0.1979883004921),
            new AminoAcid('g', 0.1975473066391),
            new AminoAcid('t', 0.3015094502008),
        };
        try (OutputStream out = new BufferedOutputStream(System.out, 1 << 16)) {
            out.write(">ONE Homo sapiens alu\n".getBytes());
            repeatFasta(out, ALU, n * 2);
            out.write(">TWO IUB ambiguity codes\n".getBytes());
            randomFasta(out, iub, n * 3);
            out.write(">THREE Homo sapiens frequency\n".getBytes());
            randomFasta(out, homoSapiens, n * 5);
        }
    }
}
