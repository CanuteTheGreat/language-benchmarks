// knucleotide - Go
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"slices"
	"strings"
)

const letters = "ACGT"

func count(s []byte, k int) map[uint64]uint32 {
	m := make(map[uint64]uint32)
	mask := uint64(1)<<(2*uint(k)) - 1
	var key uint64
	for i, c := range s {
		key = (key<<2 | uint64(c)) & mask
		if i+1 >= k {
			m[key]++
		}
	}
	return m
}

type entry struct {
	key uint64
	cnt uint32
}

func frequencies(out *bufio.Writer, s []byte, k int) {
	m := count(s, k)
	v := make([]entry, 0, len(m))
	for key, cnt := range m {
		v = append(v, entry{key, cnt})
	}
	slices.SortFunc(v, func(a, b entry) int {
		if a.cnt != b.cnt {
			return int(b.cnt) - int(a.cnt)
		}
		if a.key < b.key {
			return -1
		}
		if a.key > b.key {
			return 1
		}
		return 0
	})
	total := float64(len(s) - k + 1)
	name := make([]byte, k)
	for _, e := range v {
		for j := 0; j < k; j++ {
			name[j] = letters[(e.key>>(2*uint(k-1-j)))&3]
		}
		fmt.Fprintf(out, "%s %.3f\n", name, 100*float64(e.cnt)/total)
	}
	out.WriteByte('\n')
}

func occurrences(out *bufio.Writer, s []byte, seq string) {
	var key uint64
	for i := 0; i < len(seq); i++ {
		key = key<<2 | uint64(strings.IndexByte(letters, seq[i]))
	}
	m := count(s, len(seq))
	fmt.Fprintf(out, "%d\t%s\n", m[key], seq)
}

func main() {
	data, _ := io.ReadAll(os.Stdin)
	var s []byte
	three := false
	for _, line := range bytes.Split(data, []byte{'\n'}) {
		if len(line) > 0 && line[0] == '>' {
			three = bytes.HasPrefix(line, []byte(">THREE"))
		} else if three {
			for _, c := range line {
				switch c & 0xDF {
				case 'A':
					s = append(s, 0)
				case 'C':
					s = append(s, 1)
				case 'G':
					s = append(s, 2)
				case 'T':
					s = append(s, 3)
				}
			}
		}
	}
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	frequencies(out, s, 1)
	frequencies(out, s, 2)
	for _, q := range []string{"GGT", "GGTA", "GGTATT", "GGTATTTTAATT", "GGTATTTTAATTTATAGT"} {
		occurrences(out, s, q)
	}
}
