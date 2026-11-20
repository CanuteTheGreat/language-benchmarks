fn main() {
    let _ = regex::Regex::new("a").unwrap();
    let _: serde_json::Value = serde_json::from_str("{}").unwrap();
    let _ = num_bigint::BigUint::from(1u32);
    use rayon::prelude::*;
    let _: i32 = (0..10).into_par_iter().sum();
}
