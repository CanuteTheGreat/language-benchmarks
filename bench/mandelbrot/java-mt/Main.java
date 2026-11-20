// mandelbrot, Java, multi-threaded (parallel streams)
import java.io.*;
import java.util.stream.IntStream;

public class Main {
    static void rowBits(int n, int y, byte[] row) {
        double ci = 2.0 * y / n - 1.0;
        for (int x = 0; x < n; x++) {
            double cr = 2.0 * x / n - 1.5;
            double zr = 0, zi = 0, tr = 0, ti = 0;
            for (int i = 0; i < 50 && tr + ti <= 4.0; i++) {
                zi = 2.0 * zr * zi + ci;
                zr = tr - ti + cr;
                tr = zr * zr;
                ti = zi * zi;
            }
            if (tr + ti <= 4.0) row[x >> 3] |= (byte) (0x80 >> (x & 7));
        }
    }

    public static void main(String[] args) throws IOException {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 200;
        int rb = (n + 7) / 8;
        byte[][] rows = new byte[n][rb];
        IntStream.range(0, n).parallel().forEach(y -> rowBits(n, y, rows[y]));
        OutputStream out = new BufferedOutputStream(new FileOutputStream(FileDescriptor.out), 1 << 16);
        out.write(("P4\n" + n + " " + n + "\n").getBytes());
        for (byte[] row : rows) out.write(row);
        out.flush();
    }
}
