program gratitude_mechanism_index
  implicit none
  real :: gratitude_score, life_satisfaction, perceived_support, resilience_score
  real :: stress_load, depressive_symptoms, reflection_depth, gratitude_expression
  real :: intervention_fit, relationship_quality, social_trust
  real :: appreciative_orientation, relational_support, net_wellbeing

  gratitude_score = 7.2
  life_satisfaction = 7.1
  perceived_support = 7.3
  resilience_score = 6.9
  stress_load = 3.6
  depressive_symptoms = 3.8
  reflection_depth = 7.0
  gratitude_expression = 7.1
  intervention_fit = 7.2
  relationship_quality = 7.4
  social_trust = 7.1

  appreciative_orientation = (gratitude_score + perceived_support + reflection_depth + &
      gratitude_expression + relationship_quality + social_trust + intervention_fit - stress_load) / 8.0

  relational_support = (perceived_support + relationship_quality + social_trust + gratitude_expression) / 4.0

  net_wellbeing = life_satisfaction + gratitude_score + perceived_support + resilience_score + &
      reflection_depth + gratitude_expression + relationship_quality + social_trust - &
      depressive_symptoms - stress_load

  print *, "Appreciative orientation index:", appreciative_orientation
  print *, "Relational support index:", relational_support
  print *, "Net wellbeing index:", net_wellbeing
end program gratitude_mechanism_index
