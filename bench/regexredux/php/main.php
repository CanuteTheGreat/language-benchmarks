<?php
// regexredux - PHP (preg_*)
ini_set('memory_limit', '-1');

$input = stream_get_contents(STDIN);
$len0 = strlen($input);

$seq = preg_replace('/>.*\n|\n/', '', $input);
$len1 = strlen($seq);
unset($input);

$variants = [
    'agggtaaa|tttaccct',
    '[cgt]gggtaaa|tttaccc[acg]',
    'a[act]ggtaaa|tttacc[agt]t',
    'ag[act]gtaaa|tttac[agt]ct',
    'agg[act]taaa|ttta[agt]cct',
    'aggg[acg]aaa|ttt[cgt]ccct',
    'agggt[cgt]aa|tt[acg]accct',
    'agggta[cgt]a|t[acg]taccct',
    'agggtaa[cgt]|[acg]ttaccct',
];
foreach ($variants as $v) {
    echo $v, ' ', preg_match_all('/' . $v . '/', $seq), "\n";
}

$subs = [
    ['tHa[Nt]', '<4>'],
    ['aND|caN|Ha[DS]|WaS', '<3>'],
    ['a[NSt]|BY', '<2>'],
    ['<[^>]*>', '|'],
    ['\|[^|][^|]*\|', '-'],
];
foreach ($subs as [$pat, $rep]) {
    $seq = preg_replace('/' . $pat . '/', $rep, $seq);
}

echo "\n", $len0, "\n", $len1, "\n", strlen($seq), "\n";
