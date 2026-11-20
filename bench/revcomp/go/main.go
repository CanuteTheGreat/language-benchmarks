// revcomp - Go
package main

import (
	"bufio"
	"bytes"
	"os"
)

var comp [256]byte

func init() {
	for i := range comp {
		comp[i] = byte(i)
	}
	from, to := "ACGTUMRWSYKVHDBN", "TGCAAKYWSRMBDHVN"
	for i := 0; i < len(from); i++ {
		comp[from[i]] = to[i]
		comp[from[i]|0x20] = to[i]
	}
}

// emit writes the reverse complement of seq in lines of 60.
func emit(out *bufio.Writer, seq []byte) {
	var line [61]byte
	n := len(seq)
	for n > 0 {
		m := min(n, 60)
		for j := 0; j < m; j++ {
			n--
			line[j] = comp[seq[n]]
		}
		line[m] = '\n'
		out.Write(line[:m+1])
	}
}

func main() {
	in := bufio.NewReaderSize(os.Stdin, 1<<16)
	out := bufio.NewWriterSize(os.Stdout, 1<<16)
	defer out.Flush()
	var seq []byte
	for {
		line, err := in.ReadBytes('\n')
		line = bytes.TrimRight(line, "\n")
		if len(line) > 0 && line[0] == '>' {
			emit(out, seq)
			seq = seq[:0]
			out.Write(line)
			out.WriteByte('\n')
		} else {
			seq = append(seq, line...)
		}
		if err != nil {
			break
		}
	}
	emit(out, seq)
}
