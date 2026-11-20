// spectralnorm benchmark, Go (goroutines)
package main

import (
	"fmt"
	"math"
	"os"
	"runtime"
	"strconv"
	"sync"
)

func evalA(i, j int) float64 { return 1 / float64((i+j)*(i+j+1)/2+i+1) }

// parallelRows runs body(lo, hi) on one goroutine per CPU, each handling a contiguous chunk of rows.
func parallelRows(n int, body func(lo, hi int)) {
	workers := runtime.NumCPU()
	chunk := (n + workers - 1) / workers
	var wg sync.WaitGroup
	for lo := 0; lo < n; lo += chunk {
		hi := min(n, lo+chunk)
		wg.Add(1)
		go func() {
			defer wg.Done()
			body(lo, hi)
		}()
	}
	wg.Wait()
}

func mulAv(v, out []float64) {
	parallelRows(len(out), func(lo, hi int) {
		for i := lo; i < hi; i++ {
			sum := 0.0
			for j, x := range v {
				sum += evalA(i, j) * x
			}
			out[i] = sum
		}
	})
}

func mulAtv(v, out []float64) {
	parallelRows(len(out), func(lo, hi int) {
		for i := lo; i < hi; i++ {
			sum := 0.0
			for j, x := range v {
				sum += evalA(j, i) * x
			}
			out[i] = sum
		}
	})
}

func mulAtAv(v, out, tmp []float64) {
	mulAv(v, tmp)
	mulAtv(tmp, out)
}

func main() {
	n := 100
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	u := make([]float64, n)
	v := make([]float64, n)
	tmp := make([]float64, n)
	for i := range u {
		u[i] = 1
	}
	for i := 0; i < 10; i++ {
		mulAtAv(u, v, tmp)
		mulAtAv(v, u, tmp)
	}
	var vbv, vv float64
	for i := range u {
		vbv += u[i] * v[i]
		vv += v[i] * v[i]
	}
	fmt.Printf("%0.9f\n", math.Sqrt(vbv/vv))
}
