package main

import (
	"errors"
	"fmt"
)

func Dot(values []float64, weights []float64) (float64, error) {
	if len(values) != len(weights) {
		return 0, errors.New("values and weights must have the same length")
	}

	score := 0.0
	for i := range values {
		score += values[i] * weights[i]
	}
	return score, nil
}

func main() {
	values := []float64{7.4, 7.6, 7.0, 7.2, 6.9, 7.3, 7.1, 7.0, 6.9, 3.2}
	weights := []float64{0.13, 0.13, 0.12, 0.12, 0.12, 0.13, 0.10, 0.10, 0.10, -0.05}

	score, err := Dot(values, weights)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Future well-being index: %.3f\n", score)
}
