// binarytrees - Rust
struct Node {
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
}

fn make(depth: u32) -> Box<Node> {
    if depth == 0 {
        Box::new(Node { left: None, right: None })
    } else {
        Box::new(Node { left: Some(make(depth - 1)), right: Some(make(depth - 1)) })
    }
}

fn check(n: &Node) -> u64 {
    match (&n.left, &n.right) {
        (Some(l), Some(r)) => 1 + check(l) + check(r),
        _ => 1,
    }
}

fn main() {
    let n: u32 = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(10);
    let min_depth = 4;
    let max_depth = n.max(min_depth + 2);
    let stretch = max_depth + 1;

    println!("stretch tree of depth {}\t check: {}", stretch, check(&make(stretch)));
    let long_lived = make(max_depth);
    let mut d = min_depth;
    while d <= max_depth {
        let iters: u64 = 1 << (max_depth - d + min_depth);
        let sum: u64 = (0..iters).map(|_| check(&make(d))).sum();
        println!("{}\t trees of depth {}\t check: {}", iters, d, sum);
        d += 2;
    }
    println!("long lived tree of depth {}\t check: {}", max_depth, check(&long_lived));
}
