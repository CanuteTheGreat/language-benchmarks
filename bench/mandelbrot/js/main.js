// mandelbrot, JavaScript
const fs = require("fs");

function rowBits(n, y, buf, off) {
  const ci = 2.0 * y / n - 1.0;
  for (let x = 0; x < n; x++) {
    const cr = 2.0 * x / n - 1.5;
    let zr = 0, zi = 0, tr = 0, ti = 0;
    for (let i = 0; i < 50 && tr + ti <= 4.0; i++) {
      zi = 2.0 * zr * zi + ci;
      zr = tr - ti + cr;
      tr = zr * zr;
      ti = zi * zi;
    }
    if (tr + ti <= 4.0) buf[off + (x >> 3)] |= 0x80 >> (x & 7);
  }
}

const n = process.argv[2] ? parseInt(process.argv[2]) : 200;
const rb = (n + 7) >> 3;
const img = Buffer.alloc(rb * n);
for (let y = 0; y < n; y++) rowBits(n, y, img, y * rb);
const data = Buffer.concat([Buffer.from(`P4\n${n} ${n}\n`), img]);
for (let off = 0; off < data.length;) {
  try {
    off += fs.writeSync(1, data, off);
  } catch (e) {
    if (e.code !== "EAGAIN") throw e;
  }
}
