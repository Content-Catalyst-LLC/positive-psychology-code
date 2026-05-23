package main

import "fmt"

func Mean(values []float64) float64 {
	total := 0.0
	for _, value := range values {
		total += value
	}
	return total / float64(len(values))
}

func main() {
	lifeSatisfaction := 7.6
	positiveAffect := 7.4
	negativeAffect := 2.5
	eudaimonicValues := []float64{7.3, 7.4, 7.5, 7.7, 7.4, 7.3}
	contextualSupport := 7.5
	stressLoad := 2.8

	hedonic := lifeSatisfaction + positiveAffect - negativeAffect
	eudaimonic := Mean(eudaimonicValues)
	integrated := 0.40*hedonic + 0.45*eudaimonic + 0.20*contextualSupport - 0.20*stressLoad

	fmt.Printf("Hedonic index: %.3f\n", hedonic)
	fmt.Printf("Eudaimonic index: %.3f\n", eudaimonic)
	fmt.Printf("Integrated flourishing index: %.3f\n", integrated)
}
