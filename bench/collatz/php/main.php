<?php
// collatz - longest Collatz sequence below N, PHP
$limit = isset($argv[1]) ? (int)$argv[1] : 1000000;
$best = 1;
$bestSteps = 0;
for ($s = 1; $s < $limit; $s++) {
    $n = $s;
    $steps = 0;
    while ($n != 1) {
        $n = ($n & 1) ? 3 * $n + 1 : $n >> 1;
        $steps++;
    }
    if ($steps > $bestSteps) {
        $bestSteps = $steps;
        $best = $s;
    }
}
echo $best, " ", $bestSteps, "\n";
