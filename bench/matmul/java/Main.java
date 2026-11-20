// matmul - naive matrix multiply (i,k,j), Java
public class Main {
    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 400;
        double[][] a = new double[n][n], b = new double[n][n], c = new double[n][n];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                a[i][j] = (i + j) % 10;
                b[i][j] = (i * j) % 10;
            }
        }
        for (int i = 0; i < n; i++)
            for (int k = 0; k < n; k++)
                for (int j = 0; j < n; j++) c[i][j] += a[i][k] * b[k][j];
        double sum = 0;
        for (double[] row : c)
            for (double v : row) sum += v;
        System.out.println((long) sum);
    }
}
