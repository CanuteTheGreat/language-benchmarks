// sortstd - minstd data, slices.Sort, Go.
package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
)

func main() {
	n := 10000
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	a := make([]int32, n)
	state := int64(42)
	for i := range a {
		state = state * 48271 % 2147483647
		a[i] = int32(state)
	}
	slices.Sort(a)
	for i := 1; i < n; i++ {
		if a[i-1] > a[i] {
			os.Exit(1)
		}
	}
	fmt.Println(a[0], a[n/2], a[n-1])
}
