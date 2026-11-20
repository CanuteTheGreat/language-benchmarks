// spectralnorm benchmark, JavaScript (worker_threads + SharedArrayBuffer)
const { Worker, isMainThread, parentPort, workerData } = require('node:worker_threads');
const os = require('node:os');

function evalA(i, j) {
  return 1 / (((i + j) * (i + j + 1)) / 2 + i + 1);
}

if (!isMainThread) {
  // Worker: computes rows [lo, hi) of A*src (op 0) or A^T*src (op 1) into dst.
  const vecs = workerData.vecs.map((b) => new Float64Array(b));
  const n = vecs[0].length;
  parentPort.on('message', ({ op, src, dst, lo, hi }) => {
    const s = vecs[src], d = vecs[dst];
    for (let i = lo; i < hi; i++) {
      let sum = 0;
      if (op === 0) for (let j = 0; j < n; j++) sum += evalA(i, j) * s[j];
      else for (let j = 0; j < n; j++) sum += evalA(j, i) * s[j];
      d[i] = sum;
    }
    parentPort.postMessage(0);
  });
} else {
  main();
}

async function main() {
  const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 100;
  const nproc = typeof os.availableParallelism === 'function' ? os.availableParallelism() : os.cpus().length;
  const nworkers = Math.max(1, Math.min(nproc, n));
  const bufs = [0, 1, 2].map(() => new SharedArrayBuffer(n * 8));
  const [u, v, tmp] = bufs.map((b) => new Float64Array(b));
  u.fill(1);
  const workers = [];
  for (let k = 0; k < nworkers; k++) workers.push(new Worker(__filename, { workerData: { vecs: bufs } }));

  // One matrix-vector product, rows split evenly over the workers.
  const run = (op, src, dst) =>
    Promise.all(
      workers.map(
        (w, k) =>
          new Promise((resolve) => {
            w.once('message', resolve);
            w.postMessage({ op, src, dst, lo: Math.floor((k * n) / nworkers), hi: Math.floor(((k + 1) * n) / nworkers) });
          }),
      ),
    );
  const mulAtAv = async (src, dst) => {
    await run(0, src, 2);
    await run(1, 2, dst);
  };

  for (let i = 0; i < 10; i++) {
    await mulAtAv(0, 1);
    await mulAtAv(1, 0);
  }
  let vbv = 0, vv = 0;
  for (let i = 0; i < n; i++) {
    vbv += u[i] * v[i];
    vv += v[i] * v[i];
  }
  console.log(Math.sqrt(vbv / vv).toFixed(9));
  await Promise.all(workers.map((w) => w.terminate()));
}
