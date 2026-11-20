// json - parse, walk and re-serialise with encoding/json into any
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	data, err := os.ReadFile(os.Args[1])
	if err != nil {
		panic(err)
	}
	var root any
	if err := json.Unmarshal(data, &root); err != nil {
		panic(err)
	}

	count, active := 0, 0
	var score float64
	for _, r := range root.([]any) {
		rec := r.(map[string]any)
		count++
		if a, ok := rec["active"].(bool); ok && a {
			active++
		}
		if s, ok := rec["score"].(float64); ok {
			score += s
		}
	}

	out, err := json.Marshal(root)
	if err != nil {
		panic(err)
	}
	fmt.Printf("%d %d %d %d\n", count, active, int64(score), len(out))
}
