package main

import "fmt"

type SDTIndicators struct {
	AutonomySupport      float64
	CompetenceSupport    float64
	RelatednessSupport   float64
	NeedFrustration      float64
	ControllingPressure  float64
	AutonomousMotivation float64
	ControlledMotivation float64
	Internalization      float64
	WellbeingScore       float64
	Vitality             float64
	StressLoad           float64
	ClimateQuality       float64
}

func NeedSupportIndex(x SDTIndicators) float64 {
	return (x.AutonomySupport + x.CompetenceSupport + x.RelatednessSupport) / 3.0
}

func NeedBalanceIndex(x SDTIndicators) float64 {
	return NeedSupportIndex(x) - x.NeedFrustration - x.ControllingPressure
}

func MotivationalQualityIndex(x SDTIndicators) float64 {
	return x.AutonomousMotivation + x.Internalization - x.ControlledMotivation
}

func NetSDTWellbeingIndex(x SDTIndicators) float64 {
	return x.WellbeingScore +
		x.Vitality +
		x.AutonomousMotivation +
		x.Internalization +
		NeedSupportIndex(x) -
		x.ControlledMotivation -
		x.StressLoad -
		x.NeedFrustration -
		x.ControllingPressure
}

func main() {
	example := SDTIndicators{7.4, 7.3, 7.5, 2.0, 2.4, 7.3, 2.8, 6.9, 7.4, 7.3, 2.9, 7.6}
	fmt.Printf("Need support index: %.3f\n", NeedSupportIndex(example))
	fmt.Printf("Need balance index: %.3f\n", NeedBalanceIndex(example))
	fmt.Printf("Motivational quality index: %.3f\n", MotivationalQualityIndex(example))
	fmt.Printf("Net SDT wellbeing index: %.3f\n", NetSDTWellbeingIndex(example))
}
