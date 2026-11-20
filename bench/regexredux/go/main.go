// regexredux - Go (regexp)
package main

import (
	"fmt"
	"io"
	"os"
	"regexp"
)

func re(pattern string) *regexp.Regexp {
	return regexp.MustCompile(pattern)
}

func main() {
	input, _ := io.ReadAll(os.Stdin)
	len0 := len(input)

	seq := re(">.*\n|\n").ReplaceAll(input, nil)
	len1 := len(seq)

	variants := []string{
		"agggtaaa|tttaccct",
		"[cgt]gggtaaa|tttaccc[acg]",
		"a[act]ggtaaa|tttacc[agt]t",
		"ag[act]gtaaa|tttac[agt]ct",
		"agg[act]taaa|ttta[agt]cct",
		"aggg[acg]aaa|ttt[cgt]ccct",
		"agggt[cgt]aa|tt[acg]accct",
		"agggta[cgt]a|t[acg]taccct",
		"agggtaa[cgt]|[acg]ttaccct",
	}
	for _, v := range variants {
		fmt.Printf("%s %d\n", v, len(re(v).FindAllIndex(seq, -1)))
	}

	subs := [][2]string{
		{"tHa[Nt]", "<4>"},
		{"aND|caN|Ha[DS]|WaS", "<3>"},
		{"a[NSt]|BY", "<2>"},
		{"<[^>]*>", "|"},
		{`\|[^|][^|]*\|`, "-"},
	}
	for _, s := range subs {
		seq = re(s[0]).ReplaceAll(seq, []byte(s[1]))
	}
	fmt.Printf("\n%d\n%d\n%d\n", len0, len1, len(seq))
}
