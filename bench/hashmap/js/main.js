// hashmap - minstd keys, Map, JavaScript.
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10000;
const map = new Map();
let s1 = 42;
for (let i = 0; i < n; i++) {
  s1 = (s1 * 48271) % 2147483647;
  map.set(s1, i);
}
let s2 = 42;
let hits = 0;
let sum = 0;
for (let j = 0; j < 2 * n; j++) {
  s2 = (s2 * 48271) % 2147483647;
  const v = map.get(s2);
  if (v !== undefined) {
    hits++;
    sum += v;
  }
}
console.log(`${map.size} ${hits} ${sum}`);
