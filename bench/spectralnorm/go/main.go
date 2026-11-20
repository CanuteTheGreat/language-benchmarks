// spectralnorm benchmark, Go
package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
)

func evalA(i, j int) float64 { return 1 / float64((i+j)*(i+j+1)/2+i+1) }

func mulAv(v, out []float64) {
	for i := range out {
		sum := 0.0
		for j, x := range v {
			sum += evalA(i, j) * x
		}
		out[i] = sum
	}
}

func mulAtv(v, out []float64) {
	for i := range out {
		sum := 0.0
		for j, x := range v {
			sum += evalA(j, i) * x
		}
		out[i] = sum
	}
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
