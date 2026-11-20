// collatz - longest Collatz sequence below N, Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	limit := int64(1000000)
	if len(os.Args) > 1 {
		limit, _ = strconv.ParseInt(os.Args[1], 10, 64)
	}
	best, bestSteps := int64(1), 0
	for s := int64(1); s < limit; s++ {
		n, steps := s, 0
		for n != 1 {
			if n%2 == 1 {
				n = 3*n + 1
			} else {
				n /= 2
			}
			steps++
		}
		if steps > bestSteps {
			bestSteps, best = steps, s
		}
	}
	fmt.Println(best, bestSteps)
}
