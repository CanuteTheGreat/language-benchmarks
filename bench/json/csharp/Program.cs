// json - parse, walk and re-serialise with System.Text.Json.Nodes
using System.Text;
using System.Text.Json.Nodes;

JsonNode root = JsonNode.Parse(File.ReadAllText(args[0]));

long count = 0, active = 0, score = 0;
foreach (JsonNode rec in root.AsArray())
{
    count++;
    if ((bool)rec["active"]) active++;
    score += (long)rec["score"];
}

string output = root.ToJsonString();
Console.WriteLine($"{count} {active} {score} {Encoding.UTF8.GetByteCount(output)}");
