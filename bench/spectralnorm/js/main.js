// spectralnorm benchmark, JavaScript
function evalA(i, j) {
  return 1 / (((i + j) * (i + j + 1)) / 2 + i + 1);
}

function mulAv(v, out) {
  const n = v.length;
  for (let i = 0; i < n; i++) {
    let sum = 0;
    for (let j = 0; j < n; j++) sum += evalA(i, j) * v[j];
    out[i] = sum;
  }
}

function mulAtv(v, out) {
  const n = v.length;
  for (let i = 0; i < n; i++) {
    let sum = 0;
    for (let j = 0; j < n; j++) sum += evalA(j, i) * v[j];
    out[i] = sum;
  }
}

function mulAtAv(v, out, tmp) {
  mulAv(v, tmp);
  mulAtv(tmp, out);
}

const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 100;
const u = new Float64Array(n).fill(1);
const v = new Float64Array(n);
const tmp = new Float64Array(n);
for (let i = 0; i < 10; i++) {
  mulAtAv(u, v, tmp);
  mulAtAv(v, u, tmp);
}
let vbv = 0, vv = 0;
for (let i = 0; i < n; i++) {
  vbv += u[i] * v[i];
  vv += v[i] * v[i];
}
console.log(Math.sqrt(vbv / vv).toFixed(9));
