package main

import "fmt"

type BroadenBuildIndicators struct {
	PositiveEmotion      float64
	NegativeEmotion      float64
	CognitiveFlexibility float64
	ExploratoryBehavior  float64
	AffiliativeBehavior  float64
	SocialSupport        float64
	ResilienceScore      float64
	StressArousal        float64
	ContextualSafety     float64
	ResourceStock        float64
	PracticeFit          float64
}

func BroadeningIndex(x BroadenBuildIndicators) float64 {
	return (x.PositiveEmotion +
		x.CognitiveFlexibility +
		x.ExploratoryBehavior +
		x.AffiliativeBehavior +
		x.ContextualSafety -
		x.NegativeEmotion) / 6.0
}

func ResourceIndex(x BroadenBuildIndicators) float64 {
	return (x.SocialSupport +
		x.ResilienceScore +
		x.ContextualSafety +
		x.ResourceStock +
		x.PracticeFit) / 5.0
}

func RecoveryCapacityIndex(x BroadenBuildIndicators) float64 {
	return (x.PositiveEmotion +
		x.SocialSupport +
		x.ContextualSafety +
		x.ResilienceScore -
		x.StressArousal -
		x.NegativeEmotion) / 6.0
}

func NetAdaptationIndex(x BroadenBuildIndicators) float64 {
	return x.PositiveEmotion +
		x.CognitiveFlexibility +
		x.ExploratoryBehavior +
		x.AffiliativeBehavior +
		x.SocialSupport +
		x.ResilienceScore +
		x.ContextualSafety +
		x.ResourceStock +
		x.PracticeFit -
		x.NegativeEmotion -
		x.StressArousal
}

func main() {
	example := BroadenBuildIndicators{7.2, 3.8, 7.1, 7.0, 7.2, 7.3, 6.9, 3.6, 7.2, 7.1, 7.3}
	fmt.Printf("Broadening index: %.3f\n", BroadeningIndex(example))
	fmt.Printf("Resource index: %.3f\n", ResourceIndex(example))
	fmt.Printf("Recovery capacity index: %.3f\n", RecoveryCapacityIndex(example))
	fmt.Printf("Net adaptation index: %.3f\n", NetAdaptationIndex(example))
}
