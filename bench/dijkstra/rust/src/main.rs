// dijkstra - minstd graph, Vec<Vec<(u32,u32)>>, std BinaryHeap with Reverse, Rust.
use std::cmp::Reverse;
use std::collections::BinaryHeap;

fn main() {
    let mut a = std::env::args().skip(1);
    let v: usize = a.next().map_or(1000, |s| s.parse().unwrap());
    let e: usize = a.next().map_or(5000, |s| s.parse().unwrap());
    let mut adj: Vec<Vec<(u32, u32)>> = vec![Vec::new(); v];
    let mut g: u64 = 42;
    let mut next = || {
        g = g * 48271 % 2147483647;
        g
    };
    for _ in 0..e {
        let from = (next() % v as u64) as usize;
        let to = (next() % v as u64) as u32;
        let w = (next() % 100 + 1) as u32;
        adj[from].push((to, w));
    }
    let mut dist = vec![u64::MAX; v];
    let mut pq = BinaryHeap::new();
    dist[0] = 0;
    pq.push(Reverse((0u64, 0u32)));
    while let Some(Reverse((d, u))) = pq.pop() {
        if d > dist[u as usize] {
            continue;
        }
        for &(t, w) in &adj[u as usize] {
            let nd = d + w as u64;
            if nd < dist[t as usize] {
                dist[t as usize] = nd;
                pq.push(Reverse((nd, t)));
            }
        }
    }
    let mut reached = 0u64;
    let mut sum = 0u64;
    let mut max = 0u64;
    for &d in &dist {
        if d != u64::MAX {
            reached += 1;
            sum += d;
            max = max.max(d);
        }
    }
    println!("{} {} {}", reached, sum, max);
}
