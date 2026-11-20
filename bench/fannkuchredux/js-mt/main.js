// fannkuchredux, JavaScript (Node), multi-threaded (worker_threads)
const { Worker, isMainThread, parentPort, workerData } = require("node:worker_threads");
const os = require("node:os");

const fact = [1];

// Process permutations with index in [start, end); returns [checksum, max flips].
function work(n, start, end) {
  const p = new Int32Array(n), pp = new Int32Array(n), q = new Int32Array(n), count = new Int32Array(n);
  let idx = start;
  for (let i = 0; i < n; i++) p[i] = i;
  for (let i = n - 1; i > 0; i--) {
    const d = Math.floor(idx / fact[i]);
    idx %= fact[i];
    count[i] = d;
    pp.set(p);
    for (let j = 0; j <= i; j++) p[j] = j + d <= i ? pp[j + d] : pp[j + d - i - 1];
  }
  let sum = 0, maxflips = 0;
  for (let k = start; k < end; k++) {
    if (k > start) {
      let first = p[1];
      p[1] = p[0];
      p[0] = first;
      let i = 1;
      while (++count[i] > i) {
        count[i++] = 0;
        const next = (p[0] = p[1]);
        for (let j = 1; j < i; j++) p[j] = p[j + 1];
        p[i] = first;
        first = next;
      }
    }
    q.set(p);
    let flips = 0;
    while (q[0] !== 0) {
      for (let i = 0, j = q[0]; i < j; i++, j--) {
        const t = q[i];
        q[i] = q[j];
        q[j] = t;
      }
      flips++;
    }
    if (flips > maxflips) maxflips = flips;
    sum += k % 2 === 0 ? flips : -flips;
  }
  return [sum, maxflips];
}

function setup(n) {
  for (let i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
}

if (isMainThread) {
  const n = process.argv[2] ? parseInt(process.argv[2], 10) : 7;
  setup(n);
  const total = fact[n];
  const nworkers = os.availableParallelism();
  const nchunks = Math.min(total, nworkers * 16);
  const size = Math.ceil(total / nchunks);
  let nextChunk = 0, chk = 0, mx = 0, running = nworkers;
  for (let w = 0; w < nworkers; w++) {
    const worker = new Worker(__filename, { workerData: { n } });
    const give = () => {
      while (nextChunk < nchunks) {
        const c = nextChunk++;
        const s = c * size, e = Math.min(total, s + size);
        if (s < e) return worker.postMessage([s, e]);
      }
      worker.postMessage(null);
    };
    worker.on("online", give);
    worker.on("message", ([cs, cm]) => {
      chk += cs;
      if (cm > mx) mx = cm;
      give();
    });
    worker.on("exit", () => {
      if (--running === 0) console.log(`${chk}\nPfannkuchen(${n}) = ${mx}`);
    });
  }
} else {
  const { n } = workerData;
  setup(n);
  parentPort.on("message", (m) => {
    if (m === null) process.exit(0);
    parentPort.postMessage(work(n, m[0], m[1]));
  });
}
