// sortstd - minstd data, sort_unstable, Rust.
fn main() {
    let n: usize = std::env::args().nth(1).and_then(|a| a.parse().ok()).unwrap_or(10000);
    let mut a = vec![0i32; n];
    let mut state: u64 = 42;
    for x in a.iter_mut() {
        state = state * 48271 % 2147483647;
        *x = state as i32;
    }
    a.sort_unstable();
    if a.windows(2).any(|w| w[0] > w[1]) {
        std::process::exit(1);
    }
    println!("{} {} {}", a[0], a[n / 2], a[n - 1]);
}
