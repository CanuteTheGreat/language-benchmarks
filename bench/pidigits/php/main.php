<?php
// pidigits - Benchmarks Game spigot with the gmp extension, PHP.
$n = isset($argv[1]) ? (int)$argv[1] : 30;
$numer = gmp_init(1);
$accum = gmp_init(0);
$denom = gmp_init(1);
$out = "";
$i = 0;
$k = 0;
while ($i < $n) {
    $k++;
    $y2 = $k * 2 + 1;
    $accum = gmp_mul(gmp_add($accum, gmp_mul($numer, 2)), $y2);
    $numer = gmp_mul($numer, $k);
    $denom = gmp_mul($denom, $y2);
    if (gmp_cmp($numer, $accum) > 0) continue;
    $d = gmp_intval(gmp_div_q(gmp_add(gmp_mul($numer, 3), $accum), $denom));
    if ($d != gmp_intval(gmp_div_q(gmp_add(gmp_mul($numer, 4), $accum), $denom))) continue;
    $out .= $d;
    $i++;
    if ($i % 10 == 0) $out .= "\t:$i\n";
    $accum = gmp_mul(gmp_sub($accum, gmp_mul($denom, $d)), 10);
    $numer = gmp_mul($numer, 10);
}
if ($n % 10 != 0) $out .= str_repeat(" ", 10 - $n % 10) . "\t:$n\n";
echo $out;
