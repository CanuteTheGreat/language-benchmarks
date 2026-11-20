// json - parse, walk and re-serialise with serde_json::Value.
use serde_json::Value;

fn main() {
    let path = std::env::args().nth(1).expect("path");
    let text = std::fs::read_to_string(path).unwrap();
    let root: Value = serde_json::from_str(&text).unwrap();

    let mut count = 0u64;
    let mut active = 0u64;
    let mut score = 0i64;
    for rec in root.as_array().unwrap() {
        count += 1;
        if rec["active"].as_bool() == Some(true) {
            active += 1;
        }
        score += rec["score"].as_i64().unwrap_or(0);
    }

    let out = serde_json::to_string(&root).unwrap();
    println!("{} {} {} {}", count, active, score, out.len());
}
