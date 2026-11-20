// matmul - naive matrix multiply (i,k,j), JavaScript
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 400;
const mk = () => Array.from({ length: n }, () => new Float64Array(n));
const a = mk(), b = mk(), c = mk();
for (let i = 0; i < n; i++) {
  for (let j = 0; j < n; j++) {
    a[i][j] = (i + j) % 10;
    b[i][j] = (i * j) % 10;
  }
}
for (let i = 0; i < n; i++) {
  for (let k = 0; k < n; k++) {
    for (let j = 0; j < n; j++) c[i][j] += a[i][k] * b[k][j];
  }
}
let sum = 0;
for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) sum += c[i][j];
console.log(String(sum));
