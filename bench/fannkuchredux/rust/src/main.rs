// fannkuchredux, Rust
const MAXN: usize = 16;

// Process permutations with index in [start, end); returns (checksum, max flips).
fn work(n: usize, fact: &[usize], start: usize, end: usize) -> (i64, i32) {
    let mut p = [0usize; MAXN];
    let mut count = [0usize; MAXN];
    let mut idx = start;
    for (i, v) in p.iter_mut().enumerate().take(n) {
        *v = i;
    }
    for i in (1..n).rev() {
        let d = idx / fact[i];
        idx %= fact[i];
        count[i] = d;
        let pp = p;
        for j in 0..=i {
            p[j] = if j + d <= i { pp[j + d] } else { pp[j + d - i - 1] };
        }
    }
    let mut sum = 0i64;
    let mut maxflips = 0i32;
    for k in start..end {
        if k > start {
            let mut first = p[1];
            p[1] = p[0];
            p[0] = first;
            let mut i = 1;
            loop {
                count[i] += 1;
                if count[i] <= i {
                    break;
                }
                count[i] = 0;
                i += 1;
                let next = p[1];
                p[0] = next;
                for j in 1..i {
                    p[j] = p[j + 1];
                }
                p[i] = first;
                first = next;
            }
        }
        let mut q = p;
        let mut flips = 0i32;
        while q[0] != 0 {
            let m = q[0];
            q[..=m].reverse();
            flips += 1;
        }
        maxflips = maxflips.max(flips);
        sum += if k % 2 == 0 { flips as i64 } else { -(flips as i64) };
    }
    (sum, maxflips)
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(7);
    let mut fact = [1usize; MAXN + 1];
    for i in 1..=n {
        fact[i] = fact[i - 1] * i;
    }
    let (chk, mx) = work(n, &fact, 0, fact[n]);
    println!("{chk}\nPfannkuchen({n}) = {mx}");
}
