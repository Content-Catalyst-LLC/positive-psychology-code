program appreciative_awareness_index
  implicit none
  real :: life_satisfaction, depressive_symptoms, gratitude_score, positive_event_salience
  real :: perceived_support, reflection_depth, stress_load, acceptability, context_fit
  real :: appreciative_awareness, net_wellbeing

  life_satisfaction = 7.4
  depressive_symptoms = 3.6
  gratitude_score = 7.2
  positive_event_salience = 7.1
  perceived_support = 7.3
  reflection_depth = 7.1
  stress_load = 3.2
  acceptability = 7.7
  context_fit = 7.6

  appreciative_awareness = (gratitude_score + positive_event_salience + perceived_support + &
      reflection_depth + acceptability + context_fit - stress_load) / 7.0

  net_wellbeing = life_satisfaction + gratitude_score + positive_event_salience + &
      perceived_support + reflection_depth - depressive_symptoms - stress_load

  print *, "Appreciative awareness index:", appreciative_awareness
  print *, "Net wellbeing index:", net_wellbeing
end program appreciative_awareness_index
