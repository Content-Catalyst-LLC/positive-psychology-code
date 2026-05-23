package main

import "fmt"

type PPIIndicators struct {
	WellbeingScore      float64
	DepressiveSymptoms float64
	GratitudeScore     float64
	StrengthsUse       float64
	HopeScore           float64
	MeaningScore        float64
	SocialSupport       float64
	AdherenceRate       float64
	InterventionFit     float64
	StressLoad          float64
	Acceptability       float64
	ContextFit           float64
}

func MechanismIndex(x PPIIndicators) float64 {
	return (x.GratitudeScore + x.StrengthsUse + x.HopeScore + x.MeaningScore + x.SocialSupport) / 5.0
}

func PracticeQualityProxy(x PPIIndicators) float64 {
	return (x.AdherenceRate + x.InterventionFit + x.Acceptability + x.ContextFit) / 4.0
}

func NetWellbeingIndex(x PPIIndicators) float64 {
	return x.WellbeingScore + x.GratitudeScore + x.StrengthsUse + x.HopeScore + x.MeaningScore + x.SocialSupport + x.InterventionFit - x.StressLoad - x.DepressiveSymptoms
}

func main() {
	example := PPIIndicators{7.2, 3.8, 7.3, 6.5, 6.6, 6.7, 7.0, 0.88, 7.4, 3.4, 7.5, 7.4}
	fmt.Printf("Mechanism index: %.3f\n", MechanismIndex(example))
	fmt.Printf("Practice quality proxy: %.3f\n", PracticeQualityProxy(example))
	fmt.Printf("Net wellbeing index: %.3f\n", NetWellbeingIndex(example))
}
