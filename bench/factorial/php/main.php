<?php
// factorial - N! with the gmp extension, PHP.
$n = isset($argv[1]) ? (int)$argv[1] : 100;
$f = gmp_init(1);
for ($i = 2; $i <= $n; $i++) {
    $f = gmp_mul($f, $i);
}
$s = gmp_strval($f);
$len = strlen($s);
$sum = 0;
for ($i = 0; $i < $len; $i++) {
    $sum += ord($s[$i]) - 48;
}
echo "$len $sum\n";
