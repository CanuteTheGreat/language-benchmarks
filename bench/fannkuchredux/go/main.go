// fannkuchredux, Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

const maxN = 16

var fact [maxN + 1]int

// work processes permutations with index in [start, end); returns checksum and max flips.
func work(n, start, end int) (int, int) {
	var p, pp, q, count [maxN]int
	idx := start
	for i := 0; i < n; i++ {
		p[i] = i
	}
	for i := n - 1; i > 0; i-- {
		d := idx / fact[i]
		idx %= fact[i]
		count[i] = d
		pp = p
		for j := 0; j <= i; j++ {
			if j+d <= i {
				p[j] = pp[j+d]
			} else {
				p[j] = pp[j+d-i-1]
			}
		}
	}
	sum, maxflips := 0, 0
	for k := start; k < end; k++ {
		if k > start {
			first := p[1]
			p[1] = p[0]
			p[0] = first
			i := 1
			for {
				count[i]++
				if count[i] <= i {
					break
				}
				count[i] = 0
				i++
				next := p[1]
				p[0] = next
				for j := 1; j < i; j++ {
					p[j] = p[j+1]
				}
				p[i] = first
				first = next
			}
		}
		q = p
		flips := 0
		for q[0] != 0 {
			for i, j := 0, q[0]; i < j; i, j = i+1, j-1 {
				q[i], q[j] = q[j], q[i]
			}
			flips++
		}
		if flips > maxflips {
			maxflips = flips
		}
		if k%2 == 0 {
			sum += flips
		} else {
			sum -= flips
		}
	}
	return sum, maxflips
}

func main() {
	n := 7
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	fact[0] = 1
	for i := 1; i <= n; i++ {
		fact[i] = fact[i-1] * i
	}
	chk, mx := work(n, 0, fact[n])
	fmt.Printf("%d\nPfannkuchen(%d) = %d\n", chk, n, mx)
}
