// quicksort - minstd data, hand-written quicksort, Go.
package main

import (
	"fmt"
	"os"
	"strconv"
)

func insertion(a []int32, lo, hi int) {
	for i := lo + 1; i <= hi; i++ {
		v := a[i]
		j := i - 1
		for j >= lo && a[j] > v {
			a[j+1] = a[j]
			j--
		}
		a[j+1] = v
	}
}

func sort(a []int32, lo, hi int) {
	for hi-lo >= 16 {
		x, y, z := a[lo], a[(lo+hi)/2], a[hi]
		var p int32
		if x < y {
			if y < z {
				p = y
			} else if x < z {
				p = z
			} else {
				p = x
			}
		} else {
			if x < z {
				p = x
			} else if y < z {
				p = z
			} else {
				p = y
			}
		}
		i, j := lo-1, hi+1
		for {
			i++
			for a[i] < p {
				i++
			}
			j--
			for a[j] > p {
				j--
			}
			if i >= j {
				break
			}
			a[i], a[j] = a[j], a[i]
		}
		if j-lo < hi-j {
			sort(a, lo, j)
			lo = j + 1
		} else {
			sort(a, j+1, hi)
			hi = j
		}
	}
	insertion(a, lo, hi)
}

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
	sort(a, 0, n-1)
	for i := 1; i < n; i++ {
		if a[i-1] > a[i] {
			os.Exit(1)
		}
	}
	fmt.Println(a[0], a[n/2], a[n-1])
}
