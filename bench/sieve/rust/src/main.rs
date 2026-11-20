// sieve - Sieve of Eratosthenes, Rust
fn main() {
    let n: usize = std::env::args().nth(1).map_or(1_000_000, |s| s.parse().unwrap());
    let mut composite = vec![false; n + 1];
    let mut i = 2;
    while i * i <= n {
        if !composite[i] {
            let mut j = i * i;
            while j <= n {
                composite[j] = true;
                j += i;
            }
        }
        i += 1;
    }
    let count = (2..=n).filter(|&i| !composite[i]).count();
    println!("{count}");
}
