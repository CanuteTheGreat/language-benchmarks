<?php
// spectralnorm benchmark, PHP
function eval_a(int $i, int $j): float {
    return 1.0 / ((($i + $j) * ($i + $j + 1) >> 1) + $i + 1);
}

function mul_av(array $v, int $n): array {
    $out = [];
    for ($i = 0; $i < $n; $i++) {
        $sum = 0.0;
        for ($j = 0; $j < $n; $j++) {
            $sum += eval_a($i, $j) * $v[$j];
        }
        $out[] = $sum;
    }
    return $out;
}

function mul_atv(array $v, int $n): array {
    $out = [];
    for ($i = 0; $i < $n; $i++) {
        $sum = 0.0;
        for ($j = 0; $j < $n; $j++) {
            $sum += eval_a($j, $i) * $v[$j];
        }
        $out[] = $sum;
    }
    return $out;
}

function mul_atav(array $v, int $n): array {
    return mul_atv(mul_av($v, $n), $n);
}

$n = $argc > 1 ? (int)$argv[1] : 100;
$u = array_fill(0, $n, 1.0);
$v = $u;
for ($i = 0; $i < 10; $i++) {
    $v = mul_atav($u, $n);
    $u = mul_atav($v, $n);
}
$vbv = 0.0;
$vv = 0.0;
for ($i = 0; $i < $n; $i++) {
    $vbv += $u[$i] * $v[$i];
    $vv += $v[$i] * $v[$i];
}
printf("%0.9f\n", sqrt($vbv / $vv));
