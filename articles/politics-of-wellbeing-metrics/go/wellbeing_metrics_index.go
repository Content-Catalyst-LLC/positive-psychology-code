package main

import "fmt"

func Dot(values []float64, weights []float64) float64 {
	if len(values) != len(weights) {
		panic("values and weights must have the same length")
	}

	score := 0.0
	for i := range values {
		score += values[i] * weights[i]
	}
	return score
}

func main() {
	values := []float64{7.4, 7.3, 6.9, 7.0, 6.8, 7.2, 7.5, 6.9, 3.0}
	weights := []float64{0.16, 0.14, 0.14, 0.14, 0.10, 0.10, 0.10, 0.08, -0.08}

	fmt.Printf("Public well-being index: %.3f\n", Dot(values, weights))
}
