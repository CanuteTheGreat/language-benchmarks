// mandelbrot, Go, multi-threaded (goroutines)
package main

import (
	"bufio"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"sync"
	"sync/atomic"
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
	img := make([]byte, rb*n)
	var next atomic.Int64
	var wg sync.WaitGroup
	for w := 0; w < runtime.NumCPU(); w++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for {
				y := int(next.Add(1)) - 1
				if y >= n {
					return
				}
				rowBits(n, y, img[y*rb:(y+1)*rb])
			}
		}()
	}
	wg.Wait()
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	fmt.Fprintf(out, "P4\n%d %d\n", n, n)
	out.Write(img)
}
