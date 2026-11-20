<?php
// levenshtein - PHP
function makeString(int &$state, int $n): string {
    $s = '';
    for ($i = 0; $i < $n; $i++) {
        $state = ($state * 48271) % 2147483647;
        $s .= 'ACGT'[$state % 4];
    }
    return $s;
}

$n = $argc > 1 ? (int)$argv[1] : 300;
$state = 42;
$s = makeString($state, $n);
$t = makeString($state, $n);

$prev = range(0, $n);
for ($i = 1; $i <= $n; $i++) {
    $cur = [$i];
    $si = $s[$i - 1];
    for ($j = 1; $j <= $n; $j++) {
        $sub = $prev[$j - 1] + ($si !== $t[$j - 1] ? 1 : 0);
        $cur[$j] = min($sub, $prev[$j] + 1, $cur[$j - 1] + 1);
    }
    $prev = $cur;
}
echo $prev[$n], "\n";
