// pidigits - Benchmarks Game spigot with BigInt, JavaScript.
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 30;
let numer = 1n, accum = 0n, denom = 1n;
let out = "";
let i = 0;
let k = 0n;
while (i < n) {
  k++;
  const y2 = k * 2n + 1n;
  accum = (accum + numer * 2n) * y2;
  numer *= k;
  denom *= y2;
  if (numer > accum) continue;
  const d = (numer * 3n + accum) / denom;
  if (d !== (numer * 4n + accum) / denom) continue;
  out += d.toString();
  i++;
  if (i % 10 === 0) out += `\t:${i}\n`;
  accum = (accum - denom * d) * 10n;
  numer *= 10n;
}
if (n % 10 !== 0) out += " ".repeat(10 - (n % 10)) + `\t:${n}\n`;
process.stdout.write(out);
