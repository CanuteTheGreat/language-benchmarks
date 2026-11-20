// json - parse, walk and re-serialise with Jackson (JsonNode)
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.nio.charset.StandardCharsets;

public class Main {
    public static void main(String[] args) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(new File(args[0]));

        long count = 0, active = 0, score = 0;
        for (JsonNode rec : root) {
            count++;
            if (rec.get("active").asBoolean()) active++;
            score += rec.get("score").asLong();
        }

        String out = mapper.writeValueAsString(root);
        System.out.println(count + " " + active + " " + score + " " + out.getBytes(StandardCharsets.UTF_8).length);
    }
}
