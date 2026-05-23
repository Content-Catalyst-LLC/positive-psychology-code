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
	values := []float64{6.9, 7.0, 7.4, 6.7, 6.5, 6.4, 7.4, 7.0, 6.0, 7.8}
	weights := []float64{0.12, 0.11, 0.12, 0.10, 0.10, 0.09, 0.12, 0.12, 0.06, 0.06}

	score, err := Dot(values, weights)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Cultural well-being index: %.3f\n", score)
}
