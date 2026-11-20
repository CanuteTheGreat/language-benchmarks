// pidigits - Benchmarks Game spigot with math/big, Go.
package main

import (
	"bufio"
	"fmt"
	"math/big"
	"os"
	"strconv"
)

var (
	numer = big.NewInt(1)
	accum = big.NewInt(0)
	denom = big.NewInt(1)
	tmp1  = new(big.Int)
	tmp2  = new(big.Int)
)

func extractDigit(nth int64) int64 {
	tmp1.Mul(numer, big.NewInt(nth))
	tmp2.Add(tmp1, accum)
	tmp1.Quo(tmp2, denom)
	return tmp1.Int64()
}

func nextTerm(k int64) {
	y2 := big.NewInt(k*2 + 1)
	tmp1.Lsh(numer, 1)
	accum.Add(accum, tmp1)
	accum.Mul(accum, y2)
	numer.Mul(numer, big.NewInt(k))
	denom.Mul(denom, y2)
}

func eliminateDigit(d int64) {
	tmp1.Mul(denom, big.NewInt(d))
	accum.Sub(accum, tmp1)
	accum.Mul(accum, big.NewInt(10))
	numer.Mul(numer, big.NewInt(10))
}

func main() {
	n := 30
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	i, k := 0, int64(0)
	for i < n {
		k++
		nextTerm(k)
		if numer.Cmp(accum) > 0 {
			continue
		}
		d := extractDigit(3)
		if d != extractDigit(4) {
			continue
		}
		fmt.Fprint(out, d)
		i++
		if i%10 == 0 {
			fmt.Fprintf(out, "\t:%d\n", i)
		}
		eliminateDigit(d)
	}
	if n%10 != 0 {
		fmt.Fprintf(out, "%*s\t:%d\n", 10-n%10, "", n)
	}
}
