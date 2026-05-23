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
	values := []float64{7.6, 7.5, 7.7, 7.6, 7.8, 7.3, 7.4, 7.5, 7.8, 2.4, 2.9}
	weights := []float64{0.12, 0.12, 0.12, 0.11, 0.11, 0.10, 0.10, 0.10, 0.10, -0.06, -0.06}

	score, err := Dot(values, weights)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Well-being economy index: %.3f\n", score)
}
