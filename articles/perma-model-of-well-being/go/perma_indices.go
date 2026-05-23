package main

import "fmt"

type PermaIndicators struct {
	PositiveEmotion      float64
	Engagement           float64
	Relationships        float64
	Meaning              float64
	Accomplishment       float64
	FlourishingScore     float64
	LifeSatisfaction     float64
	InstitutionalSupport float64
	InstitutionalBarrier float64
	AutonomySupport      float64
	FairnessScore        float64
	PsychologicalSafety  float64
	AccessScore          float64
	WorkloadStrain       float64
}

func PermaIndex(x PermaIndicators) float64 {
	return (x.PositiveEmotion + x.Engagement + x.Relationships + x.Meaning + x.Accomplishment) / 5.0
}

func InstitutionalQuality(x PermaIndicators) float64 {
	return x.InstitutionalSupport + x.AutonomySupport + x.FairnessScore +
		x.PsychologicalSafety + x.AccessScore -
		x.InstitutionalBarrier - x.WorkloadStrain
}

func ContextAdjustedFlourishing(x PermaIndicators) float64 {
	return x.FlourishingScore + x.LifeSatisfaction + PermaIndex(x) + InstitutionalQuality(x)
}

func main() {
	example := PermaIndicators{6.9, 7.1, 7.2, 7.0, 7.1, 7.1, 7.0, 7.2, 3.1, 7.1, 7.0, 7.2, 7.1, 3.4}

	fmt.Printf("PERMA index: %.3f\n", PermaIndex(example))
	fmt.Printf("Institutional quality: %.3f\n", InstitutionalQuality(example))
	fmt.Printf("Context-adjusted flourishing: %.3f\n", ContextAdjustedFlourishing(example))
}
