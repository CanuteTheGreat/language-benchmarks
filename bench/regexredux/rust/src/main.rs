// regexredux - Computer Language Benchmarks Game specification, Rust (regex crate).
use regex::Regex;
use std::io::Read;

fn re(pattern: &str) -> Regex {
    Regex::new(pattern).unwrap()
}

fn main() {
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input).unwrap();
    let len0 = input.len();

    let seq = re(">.*\n|\n").replace_all(&input, "").into_owned();
    let len1 = seq.len();
    drop(input);

    let variants = [
        "agggtaaa|tttaccct",
        "[cgt]gggtaaa|tttaccc[acg]",
        "a[act]ggtaaa|tttacc[agt]t",
        "ag[act]gtaaa|tttac[agt]ct",
        "agg[act]taaa|ttta[agt]cct",
        "aggg[acg]aaa|ttt[cgt]ccct",
        "agggt[cgt]aa|tt[acg]accct",
        "agggta[cgt]a|t[acg]taccct",
        "agggtaa[cgt]|[acg]ttaccct",
    ];
    for v in variants {
        println!("{} {}", v, re(v).find_iter(&seq).count());
    }

    let subs = [
        ("tHa[Nt]", "<4>"),
        ("aND|caN|Ha[DS]|WaS", "<3>"),
        ("a[NSt]|BY", "<2>"),
        ("<[^>]*>", "|"),
        (r"\|[^|][^|]*\|", "-"),
    ];
    let mut seq = seq;
    for (pat, rep) in subs {
        seq = re(pat).replace_all(&seq, rep).into_owned();
    }
    println!("\n{}\n{}\n{}", len0, len1, seq.len());
}
