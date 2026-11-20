<?php
// fannkuchredux, PHP

function work(int $n, array $fact, int $start, int $end): array
{
    $p = range(0, $n - 1);
    $count = array_fill(0, $n, 0);
    $idx = $start;
    for ($i = $n - 1; $i > 0; $i--) {
        $d = intdiv($idx, $fact[$i]);
        $idx %= $fact[$i];
        $count[$i] = $d;
        $pp = $p;
        for ($j = 0; $j <= $i; $j++) {
            $p[$j] = ($j + $d <= $i) ? $pp[$j + $d] : $pp[$j + $d - $i - 1];
        }
    }
    $sum = 0;
    $maxflips = 0;
    for ($k = $start; $k < $end; $k++) {
        if ($k > $start) {
            $first = $p[1];
            $p[1] = $p[0];
            $p[0] = $first;
            $i = 1;
            while (++$count[$i] > $i) {
                $count[$i++] = 0;
                $next = $p[0] = $p[1];
                for ($j = 1; $j < $i; $j++) {
                    $p[$j] = $p[$j + 1];
                }
                $p[$i] = $first;
                $first = $next;
            }
        }
        $q = $p;
        $flips = 0;
        while ($q[0] !== 0) {
            for ($i = 0, $j = $q[0]; $i < $j; $i++, $j--) {
                $t = $q[$i];
                $q[$i] = $q[$j];
                $q[$j] = $t;
            }
            $flips++;
        }
        if ($flips > $maxflips) {
            $maxflips = $flips;
        }
        $sum += ($k % 2 === 0) ? $flips : -$flips;
    }
    return [$sum, $maxflips];
}

$n = isset($argv[1]) ? (int)$argv[1] : 7;
$fact = [1];
for ($i = 1; $i <= $n; $i++) {
    $fact[$i] = $fact[$i - 1] * $i;
}
[$chk, $mx] = work($n, $fact, 0, $fact[$n]);
echo "$chk\nPfannkuchen($n) = $mx\n";
