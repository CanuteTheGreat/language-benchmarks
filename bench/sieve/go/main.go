// sieve - Sieve of Eratosthenes, Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	n := 1000000
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	composite := make([]bool, n+1)
	for i := 2; i*i <= n; i++ {
		if !composite[i] {
			for j := i * i; j <= n; j += i {
				composite[j] = true
			}
		}
	}
	count := 0
	for i := 2; i <= n; i++ {
		if !composite[i] {
			count++
		}
	}
	fmt.Println(count)
}
