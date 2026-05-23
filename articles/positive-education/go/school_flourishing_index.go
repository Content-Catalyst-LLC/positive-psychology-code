package main

import "fmt"

type PositiveEducationIndicators struct {
	AcademicScore     float64
	Engagement        float64
	Belonging         float64
	Resilience        float64
	LifeSatisfaction  float64
	SchoolClimate     float64
	TeacherSupport    float64
	PurposeLearning   float64
	StressLoad        float64
	ExclusionExposure float64
	AccessSupport     float64
	StudentVoice      float64
}

func SchoolFlourishingIndex(x PositiveEducationIndicators) float64 {
	return 0.20*x.AcademicScore +
		0.18*x.Engagement +
		0.18*((x.Belonging+x.TeacherSupport)/2.0) +
		0.18*((x.Resilience+x.LifeSatisfaction+x.PurposeLearning)/3.0) +
		0.20*((x.SchoolClimate+x.AccessSupport+x.StudentVoice)/3.0) -
		0.14*x.StressLoad -
		0.16*x.ExclusionExposure
}

func main() {
	example := PositiveEducationIndicators{82, 7.3, 7.5, 7.2, 7.4, 7.6, 7.7, 7.3, 2.9, 2.0, 7.5, 7.2}
	fmt.Printf("School flourishing index: %.3f\n", SchoolFlourishingIndex(example))
}
