// binarytrees - JavaScript (Node), worker_threads
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const os = require('os');

class Node {
  constructor(left, right) { this.left = left; this.right = right; }
}

function make(depth) {
  return depth === 0 ? new Node(null, null) : new Node(make(depth - 1), make(depth - 1));
}

function check(n) {
  return n.left === null ? 1 : 1 + check(n.left) + check(n.right);
}

if (!isMainThread) {
  const { depth, count } = workerData;
  let sum = 0;
  for (let i = 0; i < count; i++) sum += check(make(depth));
  parentPort.postMessage(sum);
} else {
  const runDepth = (depth, iters, nworkers) => {
    const per = Math.floor(iters / nworkers), extra = iters % nworkers;
    const jobs = [];
    for (let w = 0; w < nworkers; w++) {
      const count = per + (w < extra ? 1 : 0);
      if (count === 0) continue;
      jobs.push(new Promise((resolve, reject) => {
        const wk = new Worker(__filename, { workerData: { depth, count } });
        wk.once('message', resolve);
        wk.once('error', reject);
      }));
    }
    return Promise.all(jobs).then((r) => r.reduce((a, b) => a + b, 0));
  };

  (async () => {
    const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10;
    const minDepth = 4;
    const maxDepth = Math.max(n, minDepth + 2);
    const stretch = maxDepth + 1;
    const nworkers = os.availableParallelism();
    let out = `stretch tree of depth ${stretch}\t check: ${check(make(stretch))}\n`;
    const longLived = make(maxDepth);
    for (let d = minDepth; d <= maxDepth; d += 2) {
      const iters = 1 << (maxDepth - d + minDepth);
      const sum = await runDepth(d, iters, nworkers);
      out += `${iters}\t trees of depth ${d}\t check: ${sum}\n`;
    }
    out += `long lived tree of depth ${maxDepth}\t check: ${check(longLived)}\n`;
    process.stdout.write(out);
  })();
}
