<?php
// fasta - PHP
const LINE = 60;
const IM = 139968;
const IA = 3877;
const IC = 29573;

const ALU = 'GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG'
    . 'GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA'
    . 'CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT'
    . 'ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA'
    . 'GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG'
    . 'AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC'
    . 'AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA';

$iub = [
    ['a', 0.27], ['c', 0.12], ['g', 0.12], ['t', 0.27],
    ['B', 0.02], ['D', 0.02], ['H', 0.02], ['K', 0.02],
    ['M', 0.02], ['N', 0.02], ['R', 0.02], ['S', 0.02],
    ['V', 0.02], ['W', 0.02], ['Y', 0.02],
];
$homoSapiens = [
    ['a', 0.3029549426680],
    ['c', 0.1979883004921],
    ['g', 0.1975473066391],
    ['t', 0.3015094502008],
];

$last = 42;
$buf = '';

function emit(string $s): void {
    global $buf;
    $buf .= $s;
    if (strlen($buf) >= 65536) {
        echo $buf;
        $buf = '';
    }
}

function repeatFasta(string $s, int $n): void {
    $len = strlen($s);
    $pos = 0;
    while ($n > 0) {
        $m = min($n, LINE);
        $line = '';
        for ($i = 0; $i < $m; $i++) {
            $line .= $s[$pos++];
            if ($pos === $len) $pos = 0;
        }
        emit($line . "\n");
        $n -= $m;
    }
}

function randomFasta(array $genes, int $n): void {
    global $last;
    $acc = 0.0;
    $chars = [];
    $cum = [];
    foreach ($genes as [$c, $p]) {
        $acc += $p;
        $chars[] = $c;
        $cum[] = $acc;
    }
    $top = count($genes) - 1;
    while ($n > 0) {
        $m = min($n, LINE);
        $line = '';
        for ($i = 0; $i < $m; $i++) {
            $last = ($last * IA + IC) % IM;
            $r = $last / IM;
            $k = 0;
            while ($k < $top && $r >= $cum[$k]) $k++;
            $line .= $chars[$k];
        }
        emit($line . "\n");
        $n -= $m;
    }
}

$n = $argc > 1 ? (int)$argv[1] : 1000;
emit(">ONE Homo sapiens alu\n");
repeatFasta(ALU, $n * 2);
emit(">TWO IUB ambiguity codes\n");
randomFasta($iub, $n * 3);
emit(">THREE Homo sapiens frequency\n");
randomFasta($homoSapiens, $n * 5);
echo $buf;
