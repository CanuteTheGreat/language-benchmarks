// quicksort - minstd data, hand-written quicksort, Rust.
fn insertion(a: &mut [i32], lo: usize, hi: usize) {
    for i in lo + 1..=hi {
        let v = a[i];
        let mut j = i;
        while j > lo && a[j - 1] > v {
            a[j] = a[j - 1];
            j -= 1;
        }
        a[j] = v;
    }
}

fn median3(x: i32, y: i32, z: i32) -> i32 {
    if x < y {
        if y < z { y } else if x < z { z } else { x }
    } else if x < z {
        x
    } else if y < z {
        z
    } else {
        y
    }
}

// lo and hi are inclusive; isize so that j = lo - 1 cannot underflow.
fn sort(a: &mut [i32], mut lo: isize, mut hi: isize) {
    while hi - lo >= 16 {
        let p = median3(a[lo as usize], a[((lo + hi) / 2) as usize], a[hi as usize]);
        let (mut i, mut j) = (lo - 1, hi + 1);
        loop {
            i += 1;
            while a[i as usize] < p {
                i += 1;
            }
            j -= 1;
            while a[j as usize] > p {
                j -= 1;
            }
            if i >= j {
                break;
            }
            a.swap(i as usize, j as usize);
        }
        if j - lo < hi - j {
            sort(a, lo, j);
            lo = j + 1;
        } else {
            sort(a, j + 1, hi);
            hi = j;
        }
    }
    insertion(a, lo as usize, hi as usize);
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|a| a.parse().ok()).unwrap_or(10000);
    let mut a = vec![0i32; n];
    let mut state: u64 = 42;
    for x in a.iter_mut() {
        state = state * 48271 % 2147483647;
        *x = state as i32;
    }
    sort(&mut a, 0, n as isize - 1);
    if a.windows(2).any(|w| w[0] > w[1]) {
        std::process::exit(1);
    }
    println!("{} {} {}", a[0], a[n / 2], a[n - 1]);
}
