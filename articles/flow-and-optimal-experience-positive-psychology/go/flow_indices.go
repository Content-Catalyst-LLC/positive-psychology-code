package main

import (
	"fmt"
	"math"
)

type FlowIndicators struct {
	ChallengeLevel    float64
	SkillLevel        float64
	AttentionFocus    float64
	FeedbackQuality   float64
	GoalClarity       float64
	TaskMeaning       float64
	AutonomySupport   float64
	DistractionLoad   float64
	InterruptionCount float64
	FlowScore         float64
	PerformanceScore  float64
	LearningGain      float64
	FatigueScore      float64
	RecoveryQuality   float64
	WellbeingScore    float64
}

func BalanceIndex(x FlowIndicators) float64 {
	return -math.Abs(x.ChallengeLevel - x.SkillLevel)
}

func AttentionalEcology(x FlowIndicators) float64 {
	return x.AttentionFocus + x.FeedbackQuality + x.GoalClarity - x.DistractionLoad - x.InterruptionCount
}

func DeepEngagementContext(x FlowIndicators) float64 {
	return BalanceIndex(x) + x.AttentionFocus + x.FeedbackQuality + x.GoalClarity +
		x.TaskMeaning + x.AutonomySupport - x.DistractionLoad - x.InterruptionCount
}

func SustainableFlowIndex(x FlowIndicators) float64 {
	return x.FlowScore + x.TaskMeaning + x.AutonomySupport + x.RecoveryQuality -
		x.FatigueScore - x.DistractionLoad
}

func main() {
	example := FlowIndicators{7.1, 7.0, 7.3, 7.1, 7.4, 7.4, 7.2, 3.0, 1.0, 7.2, 7.3, 0.39, 3.2, 7.0, 7.2}

	fmt.Printf("Challenge-skill balance: %.3f\n", BalanceIndex(example))
	fmt.Printf("Attentional ecology: %.3f\n", AttentionalEcology(example))
	fmt.Printf("Deep engagement context: %.3f\n", DeepEngagementContext(example))
	fmt.Printf("Sustainable flow index: %.3f\n", SustainableFlowIndex(example))
}
