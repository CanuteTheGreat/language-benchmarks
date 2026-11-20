// hashmap - minstd keys, std::collections::HashMap, Rust.
use std::collections::HashMap;

fn main() {
    let n: u64 = std::env::args().nth(1).map_or(10000, |s| s.parse().unwrap());
    let mut m: HashMap<u32, u64> = HashMap::new();
    let mut s1: u64 = 42;
    for i in 0..n {
        s1 = s1 * 48271 % 2147483647;
        m.insert(s1 as u32, i);
    }
    let mut s2: u64 = 42;
    let mut hits = 0u64;
    let mut sum = 0u64;
    for _ in 0..2 * n {
        s2 = s2 * 48271 % 2147483647;
        if let Some(v) = m.get(&(s2 as u32)) {
            hits += 1;
            sum += v;
        }
    }
    println!("{} {} {}", m.len(), hits, sum);
}
