// mandelbrot, Go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func rowBits(n, y int, row []byte) {
	ci := 2.0*float64(y)/float64(n) - 1.0
	for x := 0; x < n; x++ {
		cr := 2.0*float64(x)/float64(n) - 1.5
		var zr, zi, tr, ti float64
		for i := 0; i < 50 && tr+ti <= 4.0; i++ {
			zi = 2.0*zr*zi + ci
			zr = tr - ti + cr
			tr = zr * zr
			ti = zi * zi
		}
		if tr+ti <= 4.0 {
			row[x>>3] |= 0x80 >> (x & 7)
		}
	}
}

func main() {
	n := 200
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	rb := (n + 7) / 8
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	fmt.Fprintf(out, "P4\n%d %d\n", n, n)
	row := make([]byte, rb)
	for y := 0; y < n; y++ {
		clear(row)
		rowBits(n, y, row)
		out.Write(row)
	}
}
