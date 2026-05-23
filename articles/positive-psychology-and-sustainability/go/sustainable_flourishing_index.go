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
	values := []float64{7.4, 7.3, 7.2, 7.3, 7.4, 7.3, 7.5, 7.4, 7.1, 7.5, 7.2, 7.3, 2.9, 3.0, 2.7}
	weights := []float64{0.09, 0.09, 0.08, 0.08, 0.08, 0.07, 0.09, 0.08, 0.09, 0.08, 0.08, 0.08, -0.06, -0.06, -0.06}

	score, err := Dot(values, weights)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Sustainable flourishing index: %.3f\n", score)
}
