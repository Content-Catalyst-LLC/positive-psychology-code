package main

import "fmt"

type ExplanatoryIndicators struct {
	NegStability        float64
	NegGlobality        float64
	NegPersonalization  float64
	PosStability        float64
	PosGlobality        float64
	PosInternalEffort   float64
	SetbackIntensity    float64
	Controllability     float64
	AgencyScore         float64
	SupportScore        float64
	PersistenceScore    float64
	HopeScore           float64
	WellbeingScore      float64
	DistressScore       float64
}

func ExplanatoryBurden(x ExplanatoryIndicators) float64 {
	return (x.NegStability + x.NegGlobality + x.NegPersonalization) / 3.0
}

func PositiveEventIntegration(x ExplanatoryIndicators) float64 {
	return (x.PosStability + x.PosGlobality + x.PosInternalEffort) / 3.0
}

func ContextAdjustedAgency(x ExplanatoryIndicators) float64 {
	return x.AgencyScore + x.SupportScore + x.Controllability -
		x.SetbackIntensity - ExplanatoryBurden(x)
}

func ResilientPersistenceIndex(x ExplanatoryIndicators) float64 {
	return x.PersistenceScore + x.HopeScore + x.AgencyScore + x.SupportScore +
		PositiveEventIntegration(x) - x.SetbackIntensity -
		ExplanatoryBurden(x) - x.DistressScore
}

func main() {
	example := ExplanatoryIndicators{3.8, 3.6, 3.7, 6.6, 6.4, 6.5, 4.3, 6.5, 6.6, 6.7, 6.6, 6.7, 6.6, 4.0}

	fmt.Printf("Explanatory burden: %.3f\n", ExplanatoryBurden(example))
	fmt.Printf("Positive-event integration: %.3f\n", PositiveEventIntegration(example))
	fmt.Printf("Context-adjusted agency: %.3f\n", ContextAdjustedAgency(example))
	fmt.Printf("Resilient persistence index: %.3f\n", ResilientPersistenceIndex(example))
}
