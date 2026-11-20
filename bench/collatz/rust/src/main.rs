// collatz - longest Collatz sequence below N, Rust
fn main() {
    let limit: i64 = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(1_000_000);
    let (mut best, mut best_steps) = (1i64, 0u32);
    for s in 1..limit {
        let (mut n, mut steps) = (s, 0u32);
        while n != 1 {
            n = if n % 2 == 1 { 3 * n + 1 } else { n / 2 };
            steps += 1;
        }
        if steps > best_steps {
            best_steps = steps;
            best = s;
        }
    }
    println!("{} {}", best, best_steps);
}
