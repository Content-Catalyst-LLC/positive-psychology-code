package main

import "fmt"

type HopeIndicators struct {
	AgencyScore         float64
	PathwaysScore       float64
	GoalClarity         float64
	GoalProgress        float64
	WellbeingScore      float64
	MeaningScore        float64
	StressLoad          float64
	ObstacleIntensity   float64
	SocialSupport       float64
	ResourceAccess      float64
	GoalRevisionQuality float64
	ContextSupport      float64
}

func HopeIndex(x HopeIndicators) float64 {
	return (x.AgencyScore + x.PathwaysScore) / 2.0
}

func ContextSupportIndex(x HopeIndicators) float64 {
	return (x.SocialSupport + x.ResourceAccess + x.ContextSupport) / 3.0
}

func NetPathwayContext(x HopeIndicators) float64 {
	return x.PathwaysScore + ContextSupportIndex(x) + x.GoalRevisionQuality - x.ObstacleIntensity
}

func NetFutureOrientation(x HopeIndicators) float64 {
	return x.AgencyScore +
		x.PathwaysScore +
		x.GoalClarity +
		x.GoalProgress +
		x.MeaningScore +
		ContextSupportIndex(x) -
		x.StressLoad -
		x.ObstacleIntensity
}

func main() {
	example := HopeIndicators{7.1, 7.0, 7.3, 6.8, 7.1, 7.4, 3.5, 3.7, 7.2, 6.8, 6.6, 7.0}
	fmt.Printf("Hope index: %.3f\n", HopeIndex(example))
	fmt.Printf("Context support index: %.3f\n", ContextSupportIndex(example))
	fmt.Printf("Net pathway context: %.3f\n", NetPathwayContext(example))
	fmt.Printf("Net future orientation: %.3f\n", NetFutureOrientation(example))
}
