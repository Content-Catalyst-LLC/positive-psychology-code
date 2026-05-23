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
	values := []float64{7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8}
	weights := []float64{0.15, 0.14, 0.14, 0.14, 0.14, 0.10, 0.09, -0.05, -0.05}

	fmt.Printf("Workplace flourishing index: %.3f\n", Dot(values, weights))
}
