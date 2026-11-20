// dijkstra - minstd graph, arrays of [to, w], hand-written binary heap, JavaScript.
const nv = process.argv.length > 3 ? parseInt(process.argv[2], 10) : 1000;
const ne = process.argv.length > 3 ? parseInt(process.argv[3], 10) : 5000;

const adj = Array.from({ length: nv }, () => []);
let g = 42;
const next = () => (g = (g * 48271) % 2147483647);
for (let e = 0; e < ne; e++) {
  const u = next() % nv;
  const v = next() % nv;
  const w = (next() % 100) + 1;
  adj[u].push([v, w]);
}

// binary min-heap on distance; parallel arrays avoid allocating a pair per entry
const hd = [];
const hv = [];
function push(d, v) {
  let i = hd.length;
  hd.push(d);
  hv.push(v);
  while (i > 0) {
    const p = (i - 1) >> 1;
    if (hd[p] <= d) break;
    hd[i] = hd[p];
    hv[i] = hv[p];
    i = p;
  }
  hd[i] = d;
  hv[i] = v;
}
let topD = 0;
let topV = 0;
function pop() {
  topD = hd[0];
  topV = hv[0];
  const ld = hd.pop();
  const lv = hv.pop();
  const n = hd.length;
  if (n === 0) return;
  let i = 0;
  for (;;) {
    let c = 2 * i + 1;
    if (c >= n) break;
    if (c + 1 < n && hd[c + 1] < hd[c]) c++;
    if (hd[c] >= ld) break;
    hd[i] = hd[c];
    hv[i] = hv[c];
    i = c;
  }
  hd[i] = ld;
  hv[i] = lv;
}

const dist = new Array(nv).fill(Infinity);
dist[0] = 0;
push(0, 0);
while (hd.length > 0) {
  pop();
  const d = topD;
  const u = topV;
  if (d > dist[u]) continue;
  for (const [t, w] of adj[u]) {
    const nd = d + w;
    if (nd < dist[t]) {
      dist[t] = nd;
      push(nd, t);
    }
  }
}
let reached = 0;
let sum = 0;
let max = 0;
for (const d of dist) {
  if (d !== Infinity) {
    reached++;
    sum += d;
    if (d > max) max = d;
  }
}
console.log(`${reached} ${sum} ${max}`);
