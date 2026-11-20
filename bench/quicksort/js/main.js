// quicksort - minstd data, hand-written quicksort, JavaScript.
function insertion(a, lo, hi) {
  for (let i = lo + 1; i <= hi; i++) {
    const v = a[i];
    let j = i - 1;
    while (j >= lo && a[j] > v) { a[j + 1] = a[j]; j--; }
    a[j + 1] = v;
  }
}

function sort(a, lo, hi) {
  while (hi - lo >= 16) {
    const x = a[lo], y = a[(lo + hi) >> 1], z = a[hi];
    let p;
    if (x < y) p = y < z ? y : (x < z ? z : x);
    else p = x < z ? x : (y < z ? z : y);
    let i = lo - 1, j = hi + 1;
    for (;;) {
      do i++; while (a[i] < p);
      do j--; while (a[j] > p);
      if (i >= j) break;
      const t = a[i]; a[i] = a[j]; a[j] = t;
    }
    if (j - lo < hi - j) { sort(a, lo, j); lo = j + 1; }
    else { sort(a, j + 1, hi); hi = j; }
  }
  insertion(a, lo, hi);
}

const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10000;
const a = new Array(n);
let state = 42;
for (let i = 0; i < n; i++) {
  state = (state * 48271) % 2147483647;
  a[i] = state;
}
sort(a, 0, n - 1);
for (let i = 1; i < n; i++) if (a[i - 1] > a[i]) process.exit(1);
console.log(`${a[0]} ${a[Math.floor(n / 2)]} ${a[n - 1]}`);
