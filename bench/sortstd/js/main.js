// sortstd - minstd data, Array.prototype.sort with a comparator, JavaScript.
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10000;
const a = new Array(n);
let state = 42;
for (let i = 0; i < n; i++) {
  state = (state * 48271) % 2147483647;
  a[i] = state;
}
a.sort((x, y) => x - y);
for (let i = 1; i < n; i++) if (a[i - 1] > a[i]) process.exit(1);
console.log(`${a[0]} ${a[Math.floor(n / 2)]} ${a[n - 1]}`);
