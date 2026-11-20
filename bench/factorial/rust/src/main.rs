// factorial - N! with num-bigint, Rust.
use num_bigint::BigUint;

fn main() {
    let n: u64 = std::env::args().nth(1).and_then(|a| a.parse().ok()).unwrap_or(100);
    let mut f = BigUint::from(1u32);
    for i in 2..=n {
        f *= i;
    }
    let s = f.to_string();
    let sum: u64 = s.bytes().map(|b| (b - b'0') as u64).sum();
    println!("{} {}", s.len(), sum);
}
