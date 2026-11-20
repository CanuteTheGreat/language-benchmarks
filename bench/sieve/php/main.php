<?php
// sieve - Sieve of Eratosthenes, PHP
$n = isset($argv[1]) ? (int)$argv[1] : 1000000;
$composite = new SplFixedArray($n + 1);
for ($i = 2; $i * $i <= $n; $i++) {
    if (!$composite[$i]) {
        for ($j = $i * $i; $j <= $n; $j += $i) {
            $composite[$j] = true;
        }
    }
}
$count = 0;
for ($i = 2; $i <= $n; $i++) {
    if (!$composite[$i]) $count++;
}
echo $count, "\n";
