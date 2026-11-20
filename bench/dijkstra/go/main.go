// dijkstra - minstd graph, slices of edges, container/heap, Go.
package main

import (
	"container/heap"
	"fmt"
	"math"
	"os"
	"strconv"
)

type edge struct{ to, w int32 }
type item struct {
	d int64
	v int32
}
type pq []item

func (h pq) Len() int           { return len(h) }
func (h pq) Less(i, j int) bool { return h[i].d < h[j].d }
func (h pq) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h *pq) Push(x any)        { *h = append(*h, x.(item)) }
func (h *pq) Pop() any {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[:n-1]
	return x
}

func main() {
	nv, ne := 1000, 5000
	if len(os.Args) > 2 {
		nv, _ = strconv.Atoi(os.Args[1])
		ne, _ = strconv.Atoi(os.Args[2])
	}
	adj := make([][]edge, nv)
	g := int64(42)
	next := func() int64 {
		g = g * 48271 % 2147483647
		return g
	}
	for e := 0; e < ne; e++ {
		u := next() % int64(nv)
		v := next() % int64(nv)
		w := next()%100 + 1
		adj[u] = append(adj[u], edge{int32(v), int32(w)})
	}
	dist := make([]int64, nv)
	for i := range dist {
		dist[i] = math.MaxInt64
	}
	h := &pq{}
	dist[0] = 0
	heap.Push(h, item{0, 0})
	for h.Len() > 0 {
		it := heap.Pop(h).(item)
		if it.d > dist[it.v] {
			continue
		}
		for _, e := range adj[it.v] {
			nd := it.d + int64(e.w)
			if nd < dist[e.to] {
				dist[e.to] = nd
				heap.Push(h, item{nd, e.to})
			}
		}
	}
	var reached, sum, max int64
	for _, d := range dist {
		if d != math.MaxInt64 {
			reached++
			sum += d
			if d > max {
				max = d
			}
		}
	}
	fmt.Println(reached, sum, max)
}
