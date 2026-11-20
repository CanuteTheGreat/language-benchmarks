// mandelbrot, Rust, multi-threaded (rayon)
use rayon::prelude::*;
use std::io::Write;

fn row_bits(n: usize, y: usize, row: &mut [u8]) {
    let ci = 2.0 * y as f64 / n as f64 - 1.0;
    for x in 0..n {
        let cr = 2.0 * x as f64 / n as f64 - 1.5;
        let (mut zr, mut zi, mut tr, mut ti) = (0.0f64, 0.0f64, 0.0f64, 0.0f64);
        let mut i = 0;
        while i < 50 && tr + ti <= 4.0 {
            zi = 2.0 * zr * zi + ci;
            zr = tr - ti + cr;
            tr = zr * zr;
            ti = zi * zi;
            i += 1;
        }
        if tr + ti <= 4.0 {
            row[x >> 3] |= 0x80 >> (x & 7);
        }
    }
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(200);
    let rb = n.div_ceil(8);
    let mut img = vec![0u8; rb * n];
    img.par_chunks_mut(rb).enumerate().for_each(|(y, row)| row_bits(n, y, row));
    let mut out = std::io::stdout().lock();
    write!(out, "P4\n{n} {n}\n").unwrap();
    out.write_all(&img).unwrap();
}
