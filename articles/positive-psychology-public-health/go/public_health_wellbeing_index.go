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
	values := []float64{7.4, 7.6, 7.3, 7.2, 7.5, 7.4, 7.6, 7.3, 7.1, 7.3, 3.0}
	weights := []float64{0.11, 0.12, 0.10, 0.10, 0.11, 0.10, 0.09, 0.10, 0.09, 0.10, -0.10}

	score, err := Dot(values, weights)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Public health well-being index: %.3f\n", score)
}
