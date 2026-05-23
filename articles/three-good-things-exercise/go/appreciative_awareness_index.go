package main

import "fmt"

type ThreeGoodThingsIndicators struct {
	LifeSatisfaction      float64
	DepressiveSymptoms   float64
	GratitudeScore       float64
	PositiveEventSalience float64
	PerceivedSupport     float64
	ReflectionDepth      float64
	StressLoad           float64
	Acceptability        float64
	ContextFit           float64
}

func AppreciativeAwarenessIndex(x ThreeGoodThingsIndicators) float64 {
	return (x.GratitudeScore +
		x.PositiveEventSalience +
		x.PerceivedSupport +
		x.ReflectionDepth +
		x.Acceptability +
		x.ContextFit -
		x.StressLoad) / 7.0
}

func NetWellbeingIndex(x ThreeGoodThingsIndicators) float64 {
	return x.LifeSatisfaction +
		x.GratitudeScore +
		x.PositiveEventSalience +
		x.PerceivedSupport +
		x.ReflectionDepth -
		x.DepressiveSymptoms -
		x.StressLoad
}

func main() {
	example := ThreeGoodThingsIndicators{7.4, 3.6, 7.2, 7.1, 7.3, 7.1, 3.2, 7.7, 7.6}
	fmt.Printf("Appreciative awareness index: %.3f\n", AppreciativeAwarenessIndex(example))
	fmt.Printf("Net wellbeing index: %.3f\n", NetWellbeingIndex(example))
}
