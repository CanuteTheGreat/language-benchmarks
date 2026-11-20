<?php
// dijkstra - minstd graph, per-vertex flat arrays [to, w, to, w, ...], SplMinHeap, PHP.
ini_set('memory_limit', '-1');
$nv = isset($argv[2]) ? (int)$argv[1] : 1000;
$ne = isset($argv[2]) ? (int)$argv[2] : 5000;
$adj = array_fill(0, $nv, []);
$g = 42;
for ($e = 0; $e < $ne; $e++) {
    $g = $g * 48271 % 2147483647;
    $u = $g % $nv;
    $g = $g * 48271 % 2147483647;
    $v = $g % $nv;
    $g = $g * 48271 % 2147483647;
    $adj[$u][] = $v;
    $adj[$u][] = $g % 100 + 1;
}

$dist = array_fill(0, $nv, PHP_INT_MAX);
$dist[0] = 0;
$pq = new SplMinHeap();
$pq->insert([0, 0]);
while (!$pq->isEmpty()) {
    [$d, $u] = $pq->extract();
    if ($d > $dist[$u]) continue;
    $a = $adj[$u];
    for ($k = 0, $c = count($a); $k < $c; $k += 2) {
        $v = $a[$k];
        $nd = $d + $a[$k + 1];
        if ($nd < $dist[$v]) {
            $dist[$v] = $nd;
            $pq->insert([$nd, $v]);
        }
    }
}
$reached = 0;
$sum = 0;
$max = 0;
foreach ($dist as $d) {
    if ($d !== PHP_INT_MAX) {
        $reached++;
        $sum += $d;
        if ($d > $max) $max = $d;
    }
}
echo $reached, " ", $sum, " ", $max, "\n";
