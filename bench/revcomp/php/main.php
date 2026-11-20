<?php
// revcomp - PHP
ini_set('memory_limit', '-1');

const FROM = 'ACGTUMRWSYKVHDBNacgtumrwsykvhdbn';
const TO = 'TGCAAKYWSRMBDHVNTGCAAKYWSRMBDHVN';

function emit(string $seq): void {
    if ($seq !== '') {
        echo chunk_split(strrev(strtr($seq, FROM, TO)), 60, "\n");
    }
}

$seq = '';
while (($line = fgets(STDIN)) !== false) {
    if ($line[0] === '>') {
        emit($seq);
        $seq = '';
        echo $line;
    } else {
        $seq .= rtrim($line, "\r\n");
    }
}
emit($seq);
