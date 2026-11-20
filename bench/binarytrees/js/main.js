// binarytrees - JavaScript (Node)
class Node {
  constructor(left, right) { this.left = left; this.right = right; }
}

function make(depth) {
  return depth === 0 ? new Node(null, null) : new Node(make(depth - 1), make(depth - 1));
}

function check(n) {
  return n.left === null ? 1 : 1 + check(n.left) + check(n.right);
}

const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 10;
const minDepth = 4;
const maxDepth = Math.max(n, minDepth + 2);
const stretch = maxDepth + 1;
let out = `stretch tree of depth ${stretch}\t check: ${check(make(stretch))}\n`;
const longLived = make(maxDepth);
for (let d = minDepth; d <= maxDepth; d += 2) {
  const iters = 1 << (maxDepth - d + minDepth);
  let sum = 0;
  for (let i = 0; i < iters; i++) sum += check(make(d));
  out += `${iters}\t trees of depth ${d}\t check: ${sum}\n`;
}
out += `long lived tree of depth ${maxDepth}\t check: ${check(longLived)}\n`;
process.stdout.write(out);
