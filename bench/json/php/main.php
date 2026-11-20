<?php
// json - parse, walk and re-serialise with json_decode / json_encode
ini_set('memory_limit', '-1');

$root = json_decode(file_get_contents($argv[1]), true);

$count = 0;
$active = 0;
$score = 0;
foreach ($root as $rec) {
    $count++;
    if ($rec['active'] === true) {
        $active++;
    }
    $score += $rec['score'];
}

$out = json_encode($root);
echo "$count $active $score ", strlen($out), "\n";
