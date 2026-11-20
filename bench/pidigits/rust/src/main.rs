// pidigits - Benchmarks Game spigot with num-bigint, Rust.
use num_bigint::BigInt;
use num_traits::ToPrimitive;
use std::io::Write;

struct Spigot {
    numer: BigInt,
    accum: BigInt,
    denom: BigInt,
}

impl Spigot {
    fn extract_digit(&self, nth: u32) -> u32 {
        ((&self.numer * nth + &self.accum) / &self.denom).to_u32().unwrap()
    }

    fn next_term(&mut self, k: u32) {
        let y2 = k * 2 + 1;
        self.accum = (&self.accum + &self.numer * 2u32) * y2;
        self.numer *= k;
        self.denom *= y2;
    }

    fn eliminate_digit(&mut self, d: u32) {
        self.accum -= &self.denom * d;
        self.accum *= 10u32;
        self.numer *= 10u32;
    }
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|a| a.parse().ok()).unwrap_or(30);
    let mut s = Spigot { numer: 1u32.into(), accum: 0u32.into(), denom: 1u32.into() };
    let mut out = std::io::stdout().lock();
    let (mut i, mut k) = (0usize, 0u32);
    while i < n {
        k += 1;
        s.next_term(k);
        if s.numer > s.accum {
            continue;
        }
        let d = s.extract_digit(3);
        if d != s.extract_digit(4) {
            continue;
        }
        write!(out, "{d}").unwrap();
        i += 1;
        if i % 10 == 0 {
            writeln!(out, "\t:{i}").unwrap();
        }
        s.eliminate_digit(d);
    }
    if n % 10 != 0 {
        writeln!(out, "{:width$}\t:{n}", "", width = 10 - n % 10).unwrap();
    }
}
