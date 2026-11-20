// revcomp - Computer Language Benchmarks Game specification, Rust.
use std::io::{BufRead, BufWriter, Write};

fn complement() -> [u8; 256] {
    let mut t = [0u8; 256];
    for (i, v) in t.iter_mut().enumerate() {
        *v = i as u8;
    }
    for (f, c) in b"ACGTUMRWSYKVHDBN".iter().zip(b"TGCAAKYWSRMBDHVN") {
        t[*f as usize] = *c;
        t[(*f | 0x20) as usize] = *c;
    }
    t
}

// Write the reverse complement of seq in lines of 60.
fn emit(out: &mut impl Write, seq: &[u8], comp: &[u8; 256]) {
    let mut line = Vec::with_capacity(61);
    for chunk in seq.rchunks(60) {
        line.clear();
        line.extend(chunk.iter().rev().map(|&c| comp[c as usize]));
        line.push(b'\n');
        out.write_all(&line).unwrap();
    }
}

fn main() {
    let comp = complement();
    let stdin = std::io::stdin();
    let mut out = BufWriter::with_capacity(1 << 16, std::io::stdout().lock());
    let mut seq: Vec<u8> = Vec::new();
    let mut line = Vec::new();
    let mut input = stdin.lock();
    while input.read_until(b'\n', &mut line).unwrap() > 0 {
        if line.last() == Some(&b'\n') {
            line.pop();
        }
        if line.first() == Some(&b'>') {
            emit(&mut out, &seq, &comp);
            seq.clear();
            out.write_all(&line).unwrap();
            out.write_all(b"\n").unwrap();
        } else {
            seq.extend_from_slice(&line);
        }
        line.clear();
    }
    emit(&mut out, &seq, &comp);
    out.flush().unwrap();
}
