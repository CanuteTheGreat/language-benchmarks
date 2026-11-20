// regexredux - JavaScript (Node, RegExp)
const fs = require('fs');

const re = (p) => new RegExp(p, 'g');

const input = fs.readFileSync(0, 'latin1');
const len0 = input.length;

let seq = input.replace(re('>.*\n|\n'), '');
const len1 = seq.length;

const variants = [
  'agggtaaa|tttaccct',
  '[cgt]gggtaaa|tttaccc[acg]',
  'a[act]ggtaaa|tttacc[agt]t',
  'ag[act]gtaaa|tttac[agt]ct',
  'agg[act]taaa|ttta[agt]cct',
  'aggg[acg]aaa|ttt[cgt]ccct',
  'agggt[cgt]aa|tt[acg]accct',
  'agggta[cgt]a|t[acg]taccct',
  'agggtaa[cgt]|[acg]ttaccct',
];
let out = '';
for (const v of variants) out += `${v} ${(seq.match(re(v)) || []).length}\n`;

const subs = [
  ['tHa[Nt]', '<4>'],
  ['aND|caN|Ha[DS]|WaS', '<3>'],
  ['a[NSt]|BY', '<2>'],
  ['<[^>]*>', '|'],
  ['\\|[^|][^|]*\\|', '-'],
];
for (const [pat, rep] of subs) seq = seq.replace(re(pat), rep);

out += `\n${len0}\n${len1}\n${seq.length}\n`;
process.stdout.write(out);
