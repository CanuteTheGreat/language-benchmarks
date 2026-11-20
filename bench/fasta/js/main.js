// fasta - JavaScript (Node)
const LINE = 60;
const IM = 139968, IA = 3877, IC = 29573;
let last = 42;

function rnd(max) {
  last = (last * IA + IC) % IM;
  return (max * last) / IM;
}

const ALU =
  'GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG' +
  'GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA' +
  'CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT' +
  'ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA' +
  'GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG' +
  'AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC' +
  'AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA';

const IUB = [
  ['a', 0.27], ['c', 0.12], ['g', 0.12], ['t', 0.27],
  ['B', 0.02], ['D', 0.02], ['H', 0.02], ['K', 0.02],
  ['M', 0.02], ['N', 0.02], ['R', 0.02], ['S', 0.02],
  ['V', 0.02], ['W', 0.02], ['Y', 0.02],
];
const HOMO_SAPIENS = [
  ['a', 0.3029549426680],
  ['c', 0.1979883004921],
  ['g', 0.1975473066391],
  ['t', 0.3015094502008],
];

const chunks = [];
let buf = '';
function emit(s) {
  buf += s;
  if (buf.length >= 1 << 16) {
    chunks.push(buf);
    buf = '';
  }
}

function repeatFasta(s, n) {
  let pos = 0;
  while (n > 0) {
    const m = Math.min(n, LINE);
    let line = '';
    for (let i = 0; i < m; i++) {
      line += s[pos++];
      if (pos === s.length) pos = 0;
    }
    emit(line + '\n');
    n -= m;
  }
}

function randomFasta(genes, n) {
  let acc = 0;
  const cum = genes.map(([, p]) => (acc += p));
  while (n > 0) {
    const m = Math.min(n, LINE);
    let line = '';
    for (let i = 0; i < m; i++) {
      const r = rnd(1.0);
      let k = 0;
      while (k < genes.length - 1 && r >= cum[k]) k++;
      line += genes[k][0];
    }
    emit(line + '\n');
    n -= m;
  }
}

const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 1000;
emit('>ONE Homo sapiens alu\n');
repeatFasta(ALU, n * 2);
emit('>TWO IUB ambiguity codes\n');
randomFasta(IUB, n * 3);
emit('>THREE Homo sapiens frequency\n');
randomFasta(HOMO_SAPIENS, n * 5);
chunks.push(buf);
process.stdout.write(chunks.join(''));
