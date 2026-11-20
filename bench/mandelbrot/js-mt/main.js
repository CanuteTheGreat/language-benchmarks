// mandelbrot, JavaScript, multi-threaded (worker_threads)
const { Worker, isMainThread, parentPort, workerData } = require("worker_threads");
const os = require("os");
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

if (isMainThread) {
  const n = process.argv[2] ? parseInt(process.argv[2]) : 200;
  const rb = (n + 7) >> 3;
  const img = Buffer.alloc(rb * n);
  const nw = os.availableParallelism();
  let pending = nw;
  for (let w = 0; w < nw; w++) {
    const worker = new Worker(__filename, { workerData: { n, w, nw } });
    // worker w computed rows w, w+nw, w+2nw, ... packed one after another
    worker.on("message", (rows) => {
      for (let k = 0, y = w; y < n; y += nw, k++)
        Buffer.from(rows.buffer, rows.byteOffset + k * rb, rb).copy(img, y * rb);
      if (--pending === 0) {
        const data = Buffer.concat([Buffer.from(`P4\n${n} ${n}\n`), img]);
        for (let off = 0; off < data.length;) {
          try {
            off += fs.writeSync(1, data, off);
          } catch (e) {
            if (e.code !== "EAGAIN") throw e;
          }
        }
      }
    });
  }
} else {
  const { n, w, nw } = workerData;
  const rb = (n + 7) >> 3;
  const buf = new Uint8Array(Math.ceil((n - w) / nw) * rb);
  for (let k = 0, y = w; y < n; y += nw, k++) rowBits(n, y, buf, k * rb);
  parentPort.postMessage(buf);
}
