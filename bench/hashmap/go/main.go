// hashmap - minstd keys, built-in map, Go.
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	n := 10000
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	m := make(map[int32]int64)
	s1 := int64(42)
	for i := 0; i < n; i++ {
		s1 = s1 * 48271 % 2147483647
		m[int32(s1)] = int64(i)
	}
	s2 := int64(42)
	hits := 0
	var sum int64
	for j := 0; j < 2*n; j++ {
		s2 = s2 * 48271 % 2147483647
		if v, ok := m[int32(s2)]; ok {
			hits++
			sum += v
		}
	}
	fmt.Println(len(m), hits, sum)
}
