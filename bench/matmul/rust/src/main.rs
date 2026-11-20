// matmul - naive matrix multiply (i,k,j), Rust
fn main() {
    let n: usize = std::env::args().nth(1).map_or(400, |s| s.parse().unwrap());
    let mut a = vec![vec![0.0f64; n]; n];
    let mut b = vec![vec![0.0f64; n]; n];
    let mut c = vec![vec![0.0f64; n]; n];
    for i in 0..n {
        for j in 0..n {
            a[i][j] = ((i + j) % 10) as f64;
            b[i][j] = ((i * j) % 10) as f64;
        }
    }
    for i in 0..n {
        for k in 0..n {
            let aik = a[i][k];
            for j in 0..n {
                c[i][j] += aik * b[k][j];
            }
        }
    }
    let sum: f64 = c.iter().flatten().sum();
    println!("{}", sum as i64);
}
