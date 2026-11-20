// levenshtein - Rust
struct MinStd(u64);

impl MinStd {
    fn next(&mut self) -> u64 {
        self.0 = (self.0 * 48271) % 2147483647;
        self.0
    }
}

fn make_string(rng: &mut MinStd, len: usize) -> Vec<u8> {
    (0..len).map(|_| b"ACGT"[(rng.next() % 4) as usize]).collect()
}

fn main() {
    let len: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(300);
    let mut rng = MinStd(42);
    let s = make_string(&mut rng, len);
    let t = make_string(&mut rng, len);

    let mut prev: Vec<usize> = (0..=len).collect();
    let mut cur = vec![0usize; len + 1];
    for i in 1..=len {
        cur[0] = i;
        for j in 1..=len {
            let sub = prev[j - 1] + usize::from(s[i - 1] != t[j - 1]);
            cur[j] = sub.min(prev[j] + 1).min(cur[j - 1] + 1);
        }
        std::mem::swap(&mut prev, &mut cur);
    }
    println!("{}", prev[len]);
}
