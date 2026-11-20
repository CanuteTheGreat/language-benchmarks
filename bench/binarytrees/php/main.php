<?php
// binarytrees - PHP
function make(int $depth): array {
    if ($depth === 0) return [null, null];
    return [make($depth - 1), make($depth - 1)];
}

function check(array $node): int {
    if ($node[0] === null) return 1;
    return 1 + check($node[0]) + check($node[1]);
}

$n = $argc > 1 ? (int)$argv[1] : 10;
$minDepth = 4;
$maxDepth = max($n, $minDepth + 2);
$stretch = $maxDepth + 1;
$out = "stretch tree of depth $stretch\t check: " . check(make($stretch)) . "\n";
$longLived = make($maxDepth);
for ($d = $minDepth; $d <= $maxDepth; $d += 2) {
    $iters = 1 << ($maxDepth - $d + $minDepth);
    $sum = 0;
    for ($i = 0; $i < $iters; $i++) $sum += check(make($d));
    $out .= "$iters\t trees of depth $d\t check: $sum\n";
}
$out .= "long lived tree of depth $maxDepth\t check: " . check($longLived) . "\n";
echo $out;
