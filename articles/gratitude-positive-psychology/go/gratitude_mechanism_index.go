package main

import "fmt"

type GratitudeIndicators struct {
	GratitudeScore      float64
	LifeSatisfaction    float64
	PerceivedSupport    float64
	ResilienceScore     float64
	StressLoad          float64
	DepressiveSymptoms  float64
	ReflectionDepth     float64
	GratitudeExpression float64
	InterventionFit     float64
	RelationshipQuality float64
	SocialTrust         float64
}

func AppreciativeOrientationIndex(x GratitudeIndicators) float64 {
	return (x.GratitudeScore +
		x.PerceivedSupport +
		x.ReflectionDepth +
		x.GratitudeExpression +
		x.RelationshipQuality +
		x.SocialTrust +
		x.InterventionFit -
		x.StressLoad) / 8.0
}

func RelationalSupportIndex(x GratitudeIndicators) float64 {
	return (x.PerceivedSupport +
		x.RelationshipQuality +
		x.SocialTrust +
		x.GratitudeExpression) / 4.0
}

func NetWellbeingIndex(x GratitudeIndicators) float64 {
	return x.LifeSatisfaction +
		x.GratitudeScore +
		x.PerceivedSupport +
		x.ResilienceScore +
		x.ReflectionDepth +
		x.GratitudeExpression +
		x.RelationshipQuality +
		x.SocialTrust -
		x.DepressiveSymptoms -
		x.StressLoad
}

func main() {
	example := GratitudeIndicators{7.2, 7.1, 7.3, 6.9, 3.6, 3.8, 7.0, 7.1, 7.2, 7.4, 7.1}
	fmt.Printf("Appreciative orientation index: %.3f\n", AppreciativeOrientationIndex(example))
	fmt.Printf("Relational support index: %.3f\n", RelationalSupportIndex(example))
	fmt.Printf("Net wellbeing index: %.3f\n", NetWellbeingIndex(example))
}
