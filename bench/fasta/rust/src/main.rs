// fasta - Rust
use std::io::{self, Write};

const LINE: usize = 60;
const IM: u32 = 139968;
const IA: u32 = 3877;
const IC: u32 = 29573;

const ALU: &[u8] = b"GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG\
GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA\
CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT\
ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA\
GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG\
AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC\
AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA";

const IUB: [(u8, f64); 15] = [
    (b'a', 0.27), (b'c', 0.12), (b'g', 0.12), (b't', 0.27),
    (b'B', 0.02), (b'D', 0.02), (b'H', 0.02), (b'K', 0.02),
    (b'M', 0.02), (b'N', 0.02), (b'R', 0.02), (b'S', 0.02),
    (b'V', 0.02), (b'W', 0.02), (b'Y', 0.02),
];

const HOMO_SAPIENS: [(u8, f64); 4] = [
    (b'a', 0.3029549426680),
    (b'c', 0.1979883004921),
    (b'g', 0.1975473066391),
    (b't', 0.3015094502008),
];

struct Rng {
    last: u32,
}

impl Rng {
    fn next(&mut self, max: f64) -> f64 {
        self.last = (self.last * IA + IC) % IM;
        max * self.last as f64 / IM as f64
    }
}

fn repeat_fasta(out: &mut impl Write, s: &[u8], mut n: usize) -> io::Result<()> {
    let mut pos = 0;
    while n > 0 {
        let m = n.min(LINE);
        for _ in 0..m {
            out.write_all(&[s[pos]])?;
            pos += 1;
            if pos == s.len() {
                pos = 0;
            }
        }
        out.write_all(b"\n")?;
        n -= m;
    }
    Ok(())
}

fn random_fasta(out: &mut impl Write, rng: &mut Rng, genes: &[(u8, f64)], mut n: usize) -> io::Result<()> {
    let mut cum = 0.0;
    let table: Vec<(u8, f64)> = genes
        .iter()
        .map(|&(c, p)| {
            cum += p;
            (c, cum)
        })
        .collect();
    let mut line = [0u8; LINE + 1];
    while n > 0 {
        let m = n.min(LINE);
        for slot in line.iter_mut().take(m) {
            let r = rng.next(1.0);
            let mut k = 0;
            while k < table.len() - 1 && r >= table[k].1 {
                k += 1;
            }
            *slot = table[k].0;
        }
        line[m] = b'\n';
        out.write_all(&line[..=m])?;
        n -= m;
    }
    Ok(())
}

fn main() -> io::Result<()> {
    let n: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(1000);
    let stdout = io::stdout();
    let mut out = io::BufWriter::with_capacity(1 << 16, stdout.lock());
    let mut rng = Rng { last: 42 };
    out.write_all(b">ONE Homo sapiens alu\n")?;
    repeat_fasta(&mut out, ALU, n * 2)?;
    out.write_all(b">TWO IUB ambiguity codes\n")?;
    random_fasta(&mut out, &mut rng, &IUB, n * 3)?;
    out.write_all(b">THREE Homo sapiens frequency\n")?;
    random_fasta(&mut out, &mut rng, &HOMO_SAPIENS, n * 5)?;
    out.flush()
}
