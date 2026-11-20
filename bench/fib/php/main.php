<?php
// fib - naive recursive Fibonacci, PHP
function fib(int $n): int {
    return $n < 2 ? $n : fib($n - 1) + fib($n - 2);
}

$n = isset($argv[1]) ? (int)$argv[1] : 35;
echo fib($n), "\n";
