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
	values := []float64{7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8}
	weights := []float64{0.16, 0.14, 0.12, 0.12, 0.14, 0.14, -0.04, -0.04, 0.10}

	fmt.Printf("Sustainable well-being index: %.3f\n", Dot(values, weights))
}
