// factorial - N! with math/big, Go.
package main

import (
	"fmt"
	"math/big"
	"os"
	"strconv"
)

func main() {
	n := 100
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	f := big.NewInt(1)
	for i := 2; i <= n; i++ {
		f.Mul(f, big.NewInt(int64(i)))
	}
	s := f.String()
	sum := 0
	for i := 0; i < len(s); i++ {
		sum += int(s[i] - '0')
	}
	fmt.Println(len(s), sum)
}
