<?php
// sortstd - minstd data, sort(), PHP.
$n = isset($argv[1]) ? (int)$argv[1] : 10000;
$a = array_fill(0, $n, 0);
$state = 42;
for ($i = 0; $i < $n; $i++) {
    $state = $state * 48271 % 2147483647;
    $a[$i] = $state;
}
sort($a);
for ($i = 1; $i < $n; $i++) {
    if ($a[$i - 1] > $a[$i]) exit(1);
}
echo $a[0], " ", $a[intdiv($n, 2)], " ", $a[$n - 1], "\n";
