// json - parse, walk and re-serialise with JSON.parse / JSON.stringify
const fs = require('fs');

const root = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

let count = 0;
let active = 0;
let score = 0;
for (const rec of root) {
  count++;
  if (rec.active === true) active++;
  score += rec.score;
}

const out = JSON.stringify(root);
console.log(`${count} ${active} ${score} ${Buffer.byteLength(out)}`);
