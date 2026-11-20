// fannkuchredux, JavaScript (Node)
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

const n = process.argv[2] ? parseInt(process.argv[2], 10) : 7;
for (let i = 1; i <= n; i++) fact[i] = fact[i - 1] * i;
const [chk, mx] = work(n, 0, fact[n]);
console.log(`${chk}\nPfannkuchen(${n}) = ${mx}`);
