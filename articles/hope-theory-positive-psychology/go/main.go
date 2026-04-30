package main

import "fmt"

func flourishingScore(engagement, relationships, meaning, accomplishment, health, affect, stress float64) float64 {
	return 0.15*engagement + 0.20*relationships + 0.20*meaning + 0.12*accomplishment + 0.15*health + 0.10*affect - 0.12*stress
}

func main() {
	score := flourishingScore(0.72, 0.80, 0.76, 0.65, 0.70, 0.68, 0.25)
	fmt.Printf("Flourishing score: %.3f\n", score)
}
