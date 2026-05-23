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
	values := []float64{7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4}
	weights := []float64{0.30, 0.25, -0.25, 0.10, 0.08, 0.10, -0.08}

	fmt.Printf("Subjective well-being index: %.3f\n", Dot(values, weights))
}
