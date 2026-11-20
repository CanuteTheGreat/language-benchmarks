// knucleotide - Computer Language Benchmarks Game specification, Rust.
use std::collections::HashMap;
use std::io::Read;

const LETTERS: [u8; 4] = *b"ACGT";

fn count(s: &[u8], k: usize) -> HashMap<u64, u32> {
    let mut m: HashMap<u64, u32> = HashMap::new();
    let mask = (1u64 << (2 * k)) - 1;
    let mut key = 0u64;
    for (i, &c) in s.iter().enumerate() {
        key = ((key << 2) | c as u64) & mask;
        if i + 1 >= k {
            *m.entry(key).or_insert(0) += 1;
        }
    }
    m
}

fn name(key: u64, k: usize) -> String {
    (0..k).map(|j| LETTERS[((key >> (2 * (k - 1 - j))) & 3) as usize] as char).collect()
}

fn frequencies(s: &[u8], k: usize) {
    let mut v: Vec<(u64, u32)> = count(s, k).into_iter().collect();
    v.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));
    let total = (s.len() - k + 1) as f64;
    for (key, cnt) in v {
        println!("{} {:.3}", name(key, k), 100.0 * cnt as f64 / total);
    }
    println!();
}

fn occurrences(s: &[u8], seq: &str) {
    let k = seq.len();
    let key = seq
        .bytes()
        .fold(0u64, |a, c| (a << 2) | LETTERS.iter().position(|&l| l == c).unwrap() as u64);
    let m = count(s, k);
    println!("{}\t{}", m.get(&key).copied().unwrap_or(0), seq);
}

fn main() {
    let mut data = Vec::new();
    std::io::stdin().lock().read_to_end(&mut data).unwrap();
    let mut s: Vec<u8> = Vec::new();
    let mut three = false;
    for line in data.split(|&b| b == b'\n') {
        if line.first() == Some(&b'>') {
            three = line.starts_with(b">THREE");
        } else if three {
            for &c in line {
                match c & 0xDF {
                    b'A' => s.push(0),
                    b'C' => s.push(1),
                    b'G' => s.push(2),
                    b'T' => s.push(3),
                    _ => {}
                }
            }
        }
    }
    frequencies(&s, 1);
    frequencies(&s, 2);
    for q in ["GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"] {
        occurrences(&s, q);
    }
}
