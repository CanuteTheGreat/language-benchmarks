// fib - naive recursive Fibonacci, JavaScript
function fib(n) {
  return n < 2 ? n : fib(n - 1) + fib(n - 2);
}

const n = process.argv.length > 2 ? parseInt(process.argv[2], 10) : 35;
console.log(String(fib(n)));
