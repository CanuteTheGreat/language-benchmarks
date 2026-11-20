// matmul - naive matrix multiply (i,k,j), Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func matrix(n int) [][]float64 {
	m := make([][]float64, n)
	for i := range m {
		m[i] = make([]float64, n)
	}
	return m
}

func main() {
	n := 400
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	a, b, c := matrix(n), matrix(n), matrix(n)
	for i := 0; i < n; i++ {
		for j := 0; j < n; j++ {
			a[i][j] = float64((i + j) % 10)
			b[i][j] = float64((i * j) % 10)
		}
	}
	for i := 0; i < n; i++ {
		for k := 0; k < n; k++ {
			for j := 0; j < n; j++ {
				c[i][j] += a[i][k] * b[k][j]
			}
		}
	}
	sum := 0.0
	for i := 0; i < n; i++ {
		for j := 0; j < n; j++ {
			sum += c[i][j]
		}
	}
	fmt.Println(int64(sum))
}
