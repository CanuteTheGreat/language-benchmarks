// levenshtein - Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

var state uint64 = 42

func next() uint64 {
	state = (state * 48271) % 2147483647
	return state
}

func makeString(n int) []byte {
	s := make([]byte, n)
	for i := range s {
		s[i] = "ACGT"[next()%4]
	}
	return s
}

func main() {
	n := 300
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	s := makeString(n)
	t := makeString(n)

	prev := make([]int, n+1)
	cur := make([]int, n+1)
	for j := range prev {
		prev[j] = j
	}
	for i := 1; i <= n; i++ {
		cur[0] = i
		for j := 1; j <= n; j++ {
			sub := prev[j-1]
			if s[i-1] != t[j-1] {
				sub++
			}
			cur[j] = min(sub, prev[j]+1, cur[j-1]+1)
		}
		prev, cur = cur, prev
	}
	fmt.Println(prev[n])
}
