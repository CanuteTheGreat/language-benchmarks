<?php
// quicksort - minstd data, hand-written quicksort, PHP.
function insertion(array &$a, int $lo, int $hi): void {
    for ($i = $lo + 1; $i <= $hi; $i++) {
        $v = $a[$i];
        $j = $i - 1;
        while ($j >= $lo && $a[$j] > $v) {
            $a[$j + 1] = $a[$j];
            $j--;
        }
        $a[$j + 1] = $v;
    }
}

function qsort_(array &$a, int $lo, int $hi): void {
    while ($hi - $lo >= 16) {
        $x = $a[$lo]; $y = $a[intdiv($lo + $hi, 2)]; $z = $a[$hi];
        if ($x < $y) {
            $p = $y < $z ? $y : ($x < $z ? $z : $x);
        } else {
            $p = $x < $z ? $x : ($y < $z ? $z : $y);
        }
        $i = $lo - 1;
        $j = $hi + 1;
        while (true) {
            do { $i++; } while ($a[$i] < $p);
            do { $j--; } while ($a[$j] > $p);
            if ($i >= $j) break;
            $t = $a[$i]; $a[$i] = $a[$j]; $a[$j] = $t;
        }
        if ($j - $lo < $hi - $j) {
            qsort_($a, $lo, $j);
            $lo = $j + 1;
        } else {
            qsort_($a, $j + 1, $hi);
            $hi = $j;
        }
    }
    insertion($a, $lo, $hi);
}

$n = isset($argv[1]) ? (int)$argv[1] : 10000;
$a = array_fill(0, $n, 0);
$state = 42;
for ($i = 0; $i < $n; $i++) {
    $state = $state * 48271 % 2147483647;
    $a[$i] = $state;
}
qsort_($a, 0, $n - 1);
for ($i = 1; $i < $n; $i++) {
    if ($a[$i - 1] > $a[$i]) exit(1);
}
echo $a[0], " ", $a[intdiv($n, 2)], " ", $a[$n - 1], "\n";
