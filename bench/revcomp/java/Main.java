// revcomp - Java
import java.io.*;
import java.util.Arrays;

public class Main {
    static final byte[] COMP = new byte[256];

    static {
        for (int i = 0; i < 256; i++) COMP[i] = (byte) i;
        String from = "ACGTUMRWSYKVHDBN", to = "TGCAAKYWSRMBDHVN";
        for (int i = 0; i < from.length(); i++) {
            COMP[from.charAt(i)] = (byte) to.charAt(i);
            COMP[from.charAt(i) | 0x20] = (byte) to.charAt(i);
        }
    }

    // Write the reverse complement of seq[0..n) in lines of 60.
    static void emit(OutputStream out, byte[] seq, int n) throws IOException {
        byte[] line = new byte[61];
        while (n > 0) {
            int m = Math.min(n, 60);
            for (int j = 0; j < m; j++) line[j] = COMP[seq[--n] & 0xFF];
            line[m] = '\n';
            out.write(line, 0, m + 1);
        }
    }

    public static void main(String[] args) throws IOException {
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in, "ISO-8859-1"), 1 << 16);
        OutputStream out = new BufferedOutputStream(new FileOutputStream(FileDescriptor.out), 1 << 16);
        byte[] seq = new byte[1 << 16];
        int n = 0;
        String line;
        while ((line = in.readLine()) != null) {
            if (line.startsWith(">")) {
                emit(out, seq, n);
                n = 0;
                out.write(line.getBytes("ISO-8859-1"));
                out.write('\n');
            } else {
                if (n + line.length() > seq.length) seq = Arrays.copyOf(seq, Math.max(seq.length * 2, n + line.length()));
                for (int i = 0; i < line.length(); i++) seq[n++] = (byte) line.charAt(i);
            }
        }
        emit(out, seq, n);
        out.flush();
    }
}
