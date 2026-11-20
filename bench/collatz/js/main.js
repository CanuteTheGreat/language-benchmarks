// collatz - longest Collatz sequence below N, JavaScript
const limit = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 1000000;
let best = 1, bestSteps = 0;
for (let s = 1; s < limit; s++) {
  let n = s, steps = 0;
  while (n !== 1) {
    n = n % 2 === 1 ? 3 * n + 1 : n / 2;
    steps++;
  }
  if (steps > bestSteps) {
    bestSteps = steps;
    best = s;
  }
}
console.log(best + " " + bestSteps);
