// hashmap - minstd keys, HashMap<Integer,Integer>, Java.
import java.util.HashMap;

public class Main {
    public static void main(String[] args) {
        int n = args.length > 0 ? Integer.parseInt(args[0]) : 10000;
        HashMap<Integer, Integer> map = new HashMap<>();
        long s1 = 42;
        for (int i = 0; i < n; i++) {
            s1 = s1 * 48271 % 2147483647;
            map.put((int) s1, i);
        }
        long s2 = 42;
        long hits = 0, sum = 0;
        for (int j = 0; j < 2 * n; j++) {
            s2 = s2 * 48271 % 2147483647;
            Integer v = map.get((int) s2);
            if (v != null) {
                hits++;
                sum += v;
            }
        }
        System.out.println(map.size() + " " + hits + " " + sum);
    }
}
