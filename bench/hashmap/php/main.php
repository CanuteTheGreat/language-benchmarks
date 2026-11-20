<?php
// hashmap - minstd keys, array, PHP.
ini_set('memory_limit', '-1');
$n = isset($argv[1]) ? (int)$argv[1] : 10000;
$m = [];
$s1 = 42;
for ($i = 0; $i < $n; $i++) {
    $s1 = $s1 * 48271 % 2147483647;
    $m[$s1] = $i;
}
$s2 = 42;
$hits = 0;
$sum = 0;
for ($j = 0; $j < 2 * $n; $j++) {
    $s2 = $s2 * 48271 % 2147483647;
    if (isset($m[$s2])) {
        $hits++;
        $sum += $m[$s2];
    }
}
echo count($m), " ", $hits, " ", $sum, "\n";
