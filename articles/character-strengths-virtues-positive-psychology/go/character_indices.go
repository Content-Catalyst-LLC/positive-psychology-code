package main

import "fmt"

type CharacterIndicators struct {
	Wisdom                   float64
	Courage                  float64
	Humanity                 float64
	Justice                  float64
	Temperance               float64
	Transcendence            float64
	SignatureStrengthUse     float64
	AuthenticityScore        float64
	ContextualSupport        float64
	InstitutionalSuppression float64
	StrengthOveruseRisk      float64
	FlourishingScore         float64
}

func VirtueProfileMean(x CharacterIndicators) float64 {
	return (x.Wisdom + x.Courage + x.Humanity + x.Justice + x.Temperance + x.Transcendence) / 6.0
}

func StrengthExpressionIndex(x CharacterIndicators) float64 {
	return x.SignatureStrengthUse + x.AuthenticityScore + x.ContextualSupport -
		x.InstitutionalSuppression - x.StrengthOveruseRisk
}

func ContextAdjustedFlourishing(x CharacterIndicators) float64 {
	return x.FlourishingScore + StrengthExpressionIndex(x) + x.ContextualSupport -
		x.InstitutionalSuppression - x.StrengthOveruseRisk
}

func main() {
	example := CharacterIndicators{7.2, 7.0, 7.5, 7.2, 7.0, 7.4, 7.3, 7.4, 7.2, 2.9, 2.6, 7.3}

	fmt.Printf("Virtue profile mean: %.3f\n", VirtueProfileMean(example))
	fmt.Printf("Strength-expression index: %.3f\n", StrengthExpressionIndex(example))
	fmt.Printf("Context-adjusted flourishing: %.3f\n", ContextAdjustedFlourishing(example))
}
