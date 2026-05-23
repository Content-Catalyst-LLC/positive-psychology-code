program ppi_mechanism_index
  implicit none
  real :: wellbeing_score, depressive_symptoms, gratitude_score, strengths_use
  real :: hope_score, meaning_score, social_support, adherence_rate
  real :: intervention_fit, stress_load, acceptability, context_fit
  real :: mechanism, practice_quality, net_wellbeing

  wellbeing_score = 7.2
  depressive_symptoms = 3.8
  gratitude_score = 7.3
  strengths_use = 6.5
  hope_score = 6.6
  meaning_score = 6.7
  social_support = 7.0
  adherence_rate = 0.88
  intervention_fit = 7.4
  stress_load = 3.4
  acceptability = 7.5
  context_fit = 7.4

  mechanism = (gratitude_score + strengths_use + hope_score + meaning_score + social_support) / 5.0
  practice_quality = (adherence_rate + intervention_fit + acceptability + context_fit) / 4.0
  net_wellbeing = wellbeing_score + gratitude_score + strengths_use + hope_score + meaning_score + social_support + intervention_fit - stress_load - depressive_symptoms

  print *, "Mechanism index:", mechanism
  print *, "Practice quality proxy:", practice_quality
  print *, "Net wellbeing index:", net_wellbeing
end program ppi_mechanism_index
