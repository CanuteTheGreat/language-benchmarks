// spectralnorm benchmark, Java
public class Main {
    static double evalA(int i, int j) {
        return 1.0 / ((i + j) * (i + j + 1) / 2 + i + 1);
    }

    static void mulAv(double[] v, double[] out) {
        for (int i = 0; i < out.length; i++) {
            double sum = 0;
            for (int j = 0; j < v.length; j++) sum += evalA(i, j) * v[j];
            out[i] = sum;
        }
    }

    static void mulAtv(double[] v, double[] out) {
        for (int i = 0; i < out.length; i++) {
            double sum = 0;
            for (int j = 0; j < v.length; j++) sum += evalA(j, i) * v[j];
            out[i] = sum;
        }
    }

    static void mulAtAv(double[] v, double[] out, double[] tmp) {
        mulAv(v, tmp);
        mulAtv(tmp, out);
    }

    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 100;
        double[] u = new double[n], v = new double[n], tmp = new double[n];
        java.util.Arrays.fill(u, 1.0);
        for (int i = 0; i < 10; i++) {
            mulAtAv(u, v, tmp);
            mulAtAv(v, u, tmp);
        }
        double vbv = 0, vv = 0;
        for (int i = 0; i < n; i++) {
            vbv += u[i] * v[i];
            vv += v[i] * v[i];
        }
        System.out.println(String.format(java.util.Locale.ROOT, "%.9f", Math.sqrt(vbv / vv)));
    }
}
