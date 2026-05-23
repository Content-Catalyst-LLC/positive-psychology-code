package main

import "fmt"

type HelplessnessIndicators struct {
	PerceivedControl     float64
	UncontrollableEvents float64
	StabilityScore       float64
	GlobalityScore        float64
	InternalityScore      float64
	MotivationScore       float64
	DepressiveSymptoms    float64
	AgencyScore           float64
	SupportScore          float64
	MasteryExperience     float64
	RecoveryOpportunity   float64
	FeedbackQuality       float64
	InstitutionalFairness float64
}

func HelplessnessIndex(x HelplessnessIndicators) float64 {
	return (x.StabilityScore + x.GlobalityScore + x.InternalityScore) / 3.0
}

func ControlGap(x HelplessnessIndicators) float64 {
	return x.PerceivedControl - x.UncontrollableEvents
}

func AgencyRecoveryIndex(x HelplessnessIndicators) float64 {
	return x.AgencyScore + x.SupportScore + x.MasteryExperience + x.RecoveryOpportunity +
		x.FeedbackQuality + x.InstitutionalFairness -
		x.UncontrollableEvents - HelplessnessIndex(x)
}

func MotivationProtectionIndex(x HelplessnessIndicators) float64 {
	return x.MotivationScore + x.PerceivedControl + x.AgencyScore + x.SupportScore +
		x.MasteryExperience + x.FeedbackQuality + x.InstitutionalFairness -
		x.UncontrollableEvents - HelplessnessIndex(x) - x.DepressiveSymptoms
}

func main() {
	example := HelplessnessIndicators{6.7, 4.0, 3.6, 3.5, 3.7, 6.6, 3.9, 6.7, 6.9, 6.6, 6.7, 6.9, 6.8}

	fmt.Printf("Helplessness index: %.3f\n", HelplessnessIndex(example))
	fmt.Printf("Control gap: %.3f\n", ControlGap(example))
	fmt.Printf("Agency-recovery index: %.3f\n", AgencyRecoveryIndex(example))
	fmt.Printf("Motivation-protection index: %.3f\n", MotivationProtectionIndex(example))
}
