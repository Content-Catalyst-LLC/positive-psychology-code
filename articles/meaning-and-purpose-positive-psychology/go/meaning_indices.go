package main

import "fmt"

type MeaningIndicators struct {
	MeaningPresence      float64
	MeaningSearch        float64
	PurposeScore         float64
	CoherenceScore       float64
	SignificanceScore    float64
	BelongingScore       float64
	ValueAlignment       float64
	InstitutionalSupport float64
	WellbeingScore       float64
	GoalPersistence      float64
	StressLoad           float64
	AlienationScore      float64
	IdentityIntegration  float64
	ContextQuality       float64
}

func MeaningSystemIndex(x MeaningIndicators) float64 {
	return (x.MeaningPresence +
		x.PurposeScore +
		x.CoherenceScore +
		x.SignificanceScore +
		x.BelongingScore +
		x.ValueAlignment +
		x.IdentityIntegration) / 7.0
}

func ContextAdjustedMeaning(x MeaningIndicators) float64 {
	return MeaningSystemIndex(x) + x.InstitutionalSupport + x.ContextQuality - x.StressLoad - x.AlienationScore
}

func DirectedLifeIndex(x MeaningIndicators) float64 {
	return x.PurposeScore + x.GoalPersistence + x.ValueAlignment + x.InstitutionalSupport - x.StressLoad
}

func SearchContextIndex(x MeaningIndicators) float64 {
	return x.MeaningSearch + x.StressLoad + x.AlienationScore - x.MeaningPresence - x.CoherenceScore
}

func main() {
	example := MeaningIndicators{7.1, 4.9, 7.2, 6.9, 7.1, 7.2, 7.0, 6.8, 7.1, 7.2, 3.7, 3.1, 6.9, 7.0}
	fmt.Printf("Meaning system index: %.3f\n", MeaningSystemIndex(example))
	fmt.Printf("Context-adjusted meaning: %.3f\n", ContextAdjustedMeaning(example))
	fmt.Printf("Directed-life index: %.3f\n", DirectedLifeIndex(example))
	fmt.Printf("Search-context index: %.3f\n", SearchContextIndex(example))
}
