<?php
// knucleotide - PHP
ini_set('memory_limit', '-1');

const LETTERS = 'ACGT';

function count_kmers(string $s, int $k): array {
    $d = [];
    $mask = (1 << (2 * $k)) - 1;
    $key = 0;
    $n = strlen($s);
    for ($i = 0; $i < $n; $i++) {
        $key = (($key << 2) | ord($s[$i])) & $mask;
        if ($i + 1 >= $k) {
            $d[$key] = ($d[$key] ?? 0) + 1;
        }
    }
    return $d;
}

function kmer_name(int $key, int $k): string {
    $r = '';
    for ($j = $k - 1; $j >= 0; $j--) {
        $r .= LETTERS[($key >> (2 * $j)) & 3];
    }
    return $r;
}

function frequencies(string &$out, string $s, int $k): void {
    $d = count_kmers($s, $k);
    $keys = array_keys($d);
    usort($keys, fn($a, $b) => $d[$b] <=> $d[$a] ?: $a <=> $b);
    $total = strlen($s) - $k + 1;
    foreach ($keys as $key) {
        $out .= sprintf("%s %.3f\n", kmer_name($key, $k), 100.0 * $d[$key] / $total);
    }
    $out .= "\n";
}

function occurrences(string &$out, string $s, string $seq): void {
    $key = 0;
    for ($i = 0; $i < strlen($seq); $i++) {
        $key = ($key << 2) | strpos(LETTERS, $seq[$i]);
    }
    $d = count_kmers($s, strlen($seq));
    $out .= sprintf("%d\t%s\n", $d[$key] ?? 0, $seq);
}

$parts = [];
$three = false;
foreach (explode("\n", stream_get_contents(STDIN)) as $line) {
    if (str_starts_with($line, '>')) {
        $three = str_starts_with($line, '>THREE');
    } elseif ($three) {
        $parts[] = $line;
    }
}
$s = strtr(strtoupper(str_replace("\r", '', implode('', $parts))), 'ACGT', "\x00\x01\x02\x03");
$out = '';
frequencies($out, $s, 1);
frequencies($out, $s, 2);
foreach (['GGT', 'GGTA', 'GGTATT', 'GGTATTTTAATT', 'GGTATTTTAATTTATAGT'] as $q) {
    occurrences($out, $s, $q);
}
echo $out;
