// sieve - Sieve of Eratosthenes, JavaScript
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 1000000;
const composite = new Uint8Array(n + 1);
for (let i = 2; i * i <= n; i++) {
  if (!composite[i]) {
    for (let j = i * i; j <= n; j += i) composite[j] = 1;
  }
}
let count = 0;
for (let i = 2; i <= n; i++) {
  if (!composite[i]) count++;
}
console.log(count);
