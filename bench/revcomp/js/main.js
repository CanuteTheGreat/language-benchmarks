// revcomp - JavaScript (Node)
const fs = require('fs');

const comp = new Uint8Array(256);
for (let i = 0; i < 256; i++) comp[i] = i;
const from = 'ACGTUMRWSYKVHDBN';
const to = 'TGCAAKYWSRMBDHVN';
for (let i = 0; i < from.length; i++) {
  comp[from.charCodeAt(i)] = to.charCodeAt(i);
  comp[from.charCodeAt(i) | 0x20] = to.charCodeAt(i);
}

const data = fs.readFileSync(0);
const chunks = [];

// Reverse complement of seq[0..n) in lines of 60.
function emit(seq, n) {
  if (n === 0) return;
  const lines = Math.ceil(n / 60);
  const out = Buffer.allocUnsafe(n + lines);
  let o = 0;
  let i = n;
  while (i > 0) {
    const m = Math.min(i, 60);
    for (let j = 0; j < m; j++) out[o++] = comp[seq[--i]];
    out[o++] = 10;
  }
  chunks.push(out);
}

const seq = Buffer.allocUnsafe(data.length);
let n = 0;
let pos = 0;
while (pos < data.length) {
  let end = data.indexOf(10, pos);
  if (end < 0) end = data.length;
  if (data[pos] === 62) {
    emit(seq, n);
    n = 0;
    chunks.push(data.subarray(pos, end + 1));
  } else {
    n += data.copy(seq, n, pos, end);
  }
  pos = end + 1;
}
emit(seq, n);
for (const c of chunks) fs.writeSync(1, c);
