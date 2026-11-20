<?php
// matmul - naive matrix multiply (i,k,j), PHP
$n = isset($argv[1]) ? (int)$argv[1] : 400;
$a = $b = $c = [];
for ($i = 0; $i < $n; $i++) {
    for ($j = 0; $j < $n; $j++) {
        $a[$i][$j] = (float)(($i + $j) % 10);
        $b[$i][$j] = (float)(($i * $j) % 10);
        $c[$i][$j] = 0.0;
    }
}
for ($i = 0; $i < $n; $i++) {
    for ($k = 0; $k < $n; $k++) {
        $aik = $a[$i][$k];
        for ($j = 0; $j < $n; $j++) {
            $c[$i][$j] += $aik * $b[$k][$j];
        }
    }
}
$sum = 0.0;
for ($i = 0; $i < $n; $i++) {
    for ($j = 0; $j < $n; $j++) $sum += $c[$i][$j];
}
echo (int)$sum, "\n";
