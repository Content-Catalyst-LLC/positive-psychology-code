program learned_helplessness_indices
  implicit none
  real :: perceived_control, uncontrollable_events, stability_score, globality_score, internality_score
  real :: motivation_score, depressive_symptoms, agency_score, support_score, mastery_experience
  real :: recovery_opportunity, feedback_quality, institutional_fairness
  real :: helplessness, gap, agency_recovery, motivation_protection

  perceived_control = 6.7
  uncontrollable_events = 4.0
  stability_score = 3.6
  globality_score = 3.5
  internality_score = 3.7
  motivation_score = 6.6
  depressive_symptoms = 3.9
  agency_score = 6.7
  support_score = 6.9
  mastery_experience = 6.6
  recovery_opportunity = 6.7
  feedback_quality = 6.9
  institutional_fairness = 6.8

  helplessness = (stability_score + globality_score + internality_score) / 3.0
  gap = perceived_control - uncontrollable_events
  agency_recovery = agency_score + support_score + mastery_experience + recovery_opportunity + &
      feedback_quality + institutional_fairness - uncontrollable_events - helplessness
  motivation_protection = motivation_score + perceived_control + agency_score + support_score + &
      mastery_experience + feedback_quality + institutional_fairness - uncontrollable_events - &
      helplessness - depressive_symptoms

  print *, "Helplessness index:", helplessness
  print *, "Control gap:", gap
  print *, "Agency-recovery index:", agency_recovery
  print *, "Motivation-protection index:", motivation_protection
end program learned_helplessness_indices
