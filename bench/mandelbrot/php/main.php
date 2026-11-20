<?php
// mandelbrot, PHP
$n = isset($argv[1]) ? (int)$argv[1] : 200;
$rb = ($n + 7) >> 3;
$out = fopen("php://stdout", "wb");
fwrite($out, "P4\n$n $n\n");
for ($y = 0; $y < $n; $y++) {
    $ci = 2.0 * $y / $n - 1.0;
    $bytes = array_fill(0, $rb, 0);
    for ($x = 0; $x < $n; $x++) {
        $cr = 2.0 * $x / $n - 1.5;
        $zr = $zi = $tr = $ti = 0.0;
        for ($i = 0; $i < 50; $i++) {
            $zi = 2.0 * $zr * $zi + $ci;
            $zr = $tr - $ti + $cr;
            $tr = $zr * $zr;
            $ti = $zi * $zi;
            if ($tr + $ti > 4.0) break;
        }
        if ($tr + $ti <= 4.0) $bytes[$x >> 3] |= 0x80 >> ($x & 7);
    }
    fwrite($out, pack("C*", ...$bytes));
}
fclose($out);
