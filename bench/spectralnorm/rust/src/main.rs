// spectralnorm benchmark, Rust
fn eval_a(i: usize, j: usize) -> f64 {
    1.0 / ((i + j) * (i + j + 1) / 2 + i + 1) as f64
}

fn mul_av(v: &[f64], out: &mut [f64]) {
    for (i, o) in out.iter_mut().enumerate() {
        *o = v.iter().enumerate().map(|(j, x)| eval_a(i, j) * x).sum();
    }
}

fn mul_atv(v: &[f64], out: &mut [f64]) {
    for (i, o) in out.iter_mut().enumerate() {
        *o = v.iter().enumerate().map(|(j, x)| eval_a(j, i) * x).sum();
    }
}

fn mul_atav(v: &[f64], out: &mut [f64], tmp: &mut [f64]) {
    mul_av(v, tmp);
    mul_atv(tmp, out);
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(100);
    let mut u = vec![1.0; n];
    let mut v = vec![0.0; n];
    let mut tmp = vec![0.0; n];
    for _ in 0..10 {
        mul_atav(&u, &mut v, &mut tmp);
        mul_atav(&v, &mut u, &mut tmp);
    }
    let vbv: f64 = u.iter().zip(&v).map(|(a, b)| a * b).sum();
    let vv: f64 = v.iter().map(|b| b * b).sum();
    println!("{:.9}", (vbv / vv).sqrt());
}
