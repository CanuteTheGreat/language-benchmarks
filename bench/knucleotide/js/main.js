// knucleotide - JavaScript (Node)
const fs = require('fs');

const LETTERS = 'ACGT';
const CODE = new Int8Array(256).fill(-1);
for (let i = 0; i < 4; i++) {
  CODE[LETTERS.charCodeAt(i)] = i;
  CODE[LETTERS.toLowerCase().charCodeAt(i)] = i;
}

function count(s, k) {
  const m = new Map();
  const mod = 4 ** k; // keys stay below 2^36, exact in a double
  let key = 0;
  for (let i = 0; i < s.length; i++) {
    key = (key * 4 + s[i]) % mod;
    if (i + 1 >= k) m.set(key, (m.get(key) || 0) + 1);
  }
  return m;
}

function name(key, k) {
  let r = '';
  for (let j = k - 1; j >= 0; j--) r += LETTERS[Math.floor(key / 4 ** j) % 4];
  return r;
}

function frequencies(out, s, k) {
  const v = [...count(s, k)];
  v.sort((a, b) => b[1] - a[1] || a[0] - b[0]);
  const total = s.length - k + 1;
  for (const [key, cnt] of v) out.push(`${name(key, k)} ${((100 * cnt) / total).toFixed(3)}\n`);
  out.push('\n');
}

function occurrences(out, s, seq) {
  let key = 0;
  for (const c of seq) key = key * 4 + LETTERS.indexOf(c);
  out.push(`${count(s, seq.length).get(key) || 0}\t${seq}\n`);
}

const data = fs.readFileSync(0);
const codes = [];
let three = false;
for (const line of data.toString('latin1').split('\n')) {
  if (line.startsWith('>')) {
    three = line.startsWith('>THREE');
  } else if (three) {
    for (let i = 0; i < line.length; i++) {
      const c = CODE[line.charCodeAt(i)];
      if (c >= 0) codes.push(c);
    }
  }
}
const s = Uint8Array.from(codes);
const out = [];
frequencies(out, s, 1);
frequencies(out, s, 2);
for (const q of ['GGT', 'GGTA', 'GGTATT', 'GGTATTTTAATT', 'GGTATTTTAATTTATAGT']) occurrences(out, s, q);
process.stdout.write(out.join(''));
