// factorial - N! with BigInt, JavaScript.
const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 100;
let f = 1n;
for (let i = 2n; i <= BigInt(n); i++) f *= i;
const s = f.toString();
let sum = 0;
for (let i = 0; i < s.length; i++) sum += s.charCodeAt(i) - 48;
console.log(`${s.length} ${sum}`);
