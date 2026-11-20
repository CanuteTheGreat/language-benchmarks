// binarytrees - Go
package main

import (
	"fmt"
	"os"
	"strconv"
)

type Node struct{ left, right *Node }

func build(depth int) *Node {
	if depth == 0 {
		return &Node{}
	}
	return &Node{build(depth - 1), build(depth - 1)}
}

func (n *Node) check() int {
	if n.left == nil {
		return 1
	}
	return 1 + n.left.check() + n.right.check()
}

func main() {
	n := 10
	if len(os.Args) > 1 {
		n, _ = strconv.Atoi(os.Args[1])
	}
	minDepth := 4
	maxDepth := max(n, minDepth+2)
	stretch := maxDepth + 1

	fmt.Printf("stretch tree of depth %d\t check: %d\n", stretch, build(stretch).check())
	longLived := build(maxDepth)
	for d := minDepth; d <= maxDepth; d += 2 {
		iters := 1 << (maxDepth - d + minDepth)
		sum := 0
		for i := 0; i < iters; i++ {
			sum += build(d).check()
		}
		fmt.Printf("%d\t trees of depth %d\t check: %d\n", iters, d, sum)
	}
	fmt.Printf("long lived tree of depth %d\t check: %d\n", maxDepth, longLived.check())
}
