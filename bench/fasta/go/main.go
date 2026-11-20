// fasta - Go
package main

import (
	"bufio"
	"os"
	"strconv"
)

const (
	lineLen = 60
	im      = 139968
	ia      = 3877
	ic      = 29573
)

var last uint32 = 42

func rnd(max float64) float64 {
	last = (last*ia + ic) % im
	return max * float64(last) / im
}

type aminoAcid struct {
	c byte
	p float64
}

const alu = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG" +
	"GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" +
	"CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT" +
	"ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" +
	"GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG" +
	"AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" +
	"AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"

func repeatFasta(w *bufio.Writer, s string, n int) {
	pos := 0
	line := make([]byte, 0, lineLen+1)
	for n > 0 {
		m := min(n, lineLen)
		line = line[:0]
		for i := 0; i < m; i++ {
			line = append(line, s[pos])
			pos++
			if pos == len(s) {
				pos = 0
			}
		}
		line = append(line, '\n')
		w.Write(line)
		n -= m
	}
}

func randomFasta(w *bufio.Writer, genes []aminoAcid, n int) {
	cum := 0.0
	for i := range genes {
		cum += genes[i].p
		genes[i].p = cum
	}
	line := make([]byte, 0, lineLen+1)
	for n > 0 {
		m := min(n, lineLen)
		line = line[:0]
		for i := 0; i < m; i++ {
			r := rnd(1.0)
			k := 0
			for k < len(genes)-1 && r >= genes[k].p {
				k++
			}
			line = append(line, genes[k].c)
		}
		line = append(line, '\n')
		w.Write(line)
		n -= m
	}
}

func main() {
	n := 1000
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	w := bufio.NewWriterSize(os.Stdout, 1<<16)
	defer w.Flush()

	iub := []aminoAcid{
		{'a', 0.27}, {'c', 0.12}, {'g', 0.12}, {'t', 0.27},
		{'B', 0.02}, {'D', 0.02}, {'H', 0.02}, {'K', 0.02},
		{'M', 0.02}, {'N', 0.02}, {'R', 0.02}, {'S', 0.02},
		{'V', 0.02}, {'W', 0.02}, {'Y', 0.02},
	}
	homoSapiens := []aminoAcid{
		{'a', 0.3029549426680},
		{'c', 0.1979883004921},
		{'g', 0.1975473066391},
		{'t', 0.3015094502008},
	}

	w.WriteString(">ONE Homo sapiens alu\n")
	repeatFasta(w, alu, n*2)
	w.WriteString(">TWO IUB ambiguity codes\n")
	randomFasta(w, iub, n*3)
	w.WriteString(">THREE Homo sapiens frequency\n")
	randomFasta(w, homoSapiens, n*5)
}
