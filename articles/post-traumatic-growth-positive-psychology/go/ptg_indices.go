package main

import (
	"fmt"
	"math"
)

type PTGIndicators struct {
	PTGScore              float64
	WellbeingScore        float64
	DistressScore         float64
	MeaningMaking         float64
	RestoredAgency        float64
	NarrativeIntegration  float64
	SocialSupport         float64
	ContextSupport        float64
	DeliberateRumination  float64
	IntrusiveRumination   float64
	OngoingStress         float64
	PerceivedGrowth       float64
	CorroboratedGrowth    float64
}

func IntegrationIndex(x PTGIndicators) float64 {
	return (x.MeaningMaking + x.RestoredAgency + x.NarrativeIntegration + x.SocialSupport + x.ContextSupport) / 5.0
}

func ReflectionBalance(x PTGIndicators) float64 {
	return x.DeliberateRumination - x.IntrusiveRumination
}

func GrowthDistressBalance(x PTGIndicators) float64 {
	return x.PTGScore + x.WellbeingScore + IntegrationIndex(x) - x.DistressScore - x.OngoingStress
}

func GrowthAlignment(x PTGIndicators) float64 {
	return x.PerceivedGrowth + x.CorroboratedGrowth - math.Abs(x.PerceivedGrowth-x.CorroboratedGrowth)
}

func main() {
	example := PTGIndicators{6.88, 6.8, 5.6, 6.9, 6.8, 6.8, 7.1, 6.9, 6.7, 5.3, 4.9, 7.1, 6.6}

	fmt.Printf("Integration index: %.3f\n", IntegrationIndex(example))
	fmt.Printf("Reflection balance: %.3f\n", ReflectionBalance(example))
	fmt.Printf("Growth-distress balance: %.3f\n", GrowthDistressBalance(example))
	fmt.Printf("Growth alignment: %.3f\n", GrowthAlignment(example))
}
