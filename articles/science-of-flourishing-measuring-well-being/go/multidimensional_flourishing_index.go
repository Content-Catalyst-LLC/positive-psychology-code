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
	eudaimonicValues := []float64{7.5, 7.4, 7.3}
	positiveRelations := 7.7
	accomplishment := 7.4
	healthIndex := 7.5
	contextualSupport := 7.5
	stressLoad := 2.8

	hedonic := lifeSatisfaction + positiveAffect - negativeAffect
	eudaimonic := Mean(eudaimonicValues)
	integrated := 0.25*hedonic + 0.25*eudaimonic + 0.15*positiveRelations + 0.15*accomplishment + 0.15*healthIndex + 0.15*contextualSupport - 0.15*stressLoad

	fmt.Printf("Hedonic index: %.3f\n", hedonic)
	fmt.Printf("Eudaimonic index: %.3f\n", eudaimonic)
	fmt.Printf("Integrated flourishing index: %.3f\n", integrated)
}
