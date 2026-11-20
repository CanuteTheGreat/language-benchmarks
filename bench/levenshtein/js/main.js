// levenshtein - JavaScript (Node)
let state = 42;

function next() {
  state = (state * 48271) % 2147483647;
  return state;
}

function makeString(n) {
  let s = '';
  for (let i = 0; i < n; i++) s += 'ACGT'[next() % 4];
  return s;
}

const len = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 300;
const s = makeString(len);
const t = makeString(len);

let prev = Array.from({ length: len + 1 }, (_, j) => j);
let cur = new Array(len + 1).fill(0);
for (let i = 1; i <= len; i++) {
  cur[0] = i;
  for (let j = 1; j <= len; j++) {
    const sub = prev[j - 1] + (s[i - 1] !== t[j - 1] ? 1 : 0);
    cur[j] = Math.min(sub, prev[j] + 1, cur[j - 1] + 1);
  }
  [prev, cur] = [cur, prev];
}
console.log(prev[len]);
