program broaden_build_index
  implicit none
  real :: positive_emotion, negative_emotion, cognitive_flexibility, exploratory_behavior
  real :: affiliative_behavior, social_support, resilience_score, stress_arousal
  real :: contextual_safety, resource_stock, practice_fit
  real :: broadening, resource, recovery, net_adaptation

  positive_emotion = 7.2
  negative_emotion = 3.8
  cognitive_flexibility = 7.1
  exploratory_behavior = 7.0
  affiliative_behavior = 7.2
  social_support = 7.3
  resilience_score = 6.9
  stress_arousal = 3.6
  contextual_safety = 7.2
  resource_stock = 7.1
  practice_fit = 7.3

  broadening = (positive_emotion + cognitive_flexibility + exploratory_behavior + &
      affiliative_behavior + contextual_safety - negative_emotion) / 6.0

  resource = (social_support + resilience_score + contextual_safety + resource_stock + practice_fit) / 5.0

  recovery = (positive_emotion + social_support + contextual_safety + resilience_score - &
      stress_arousal - negative_emotion) / 6.0

  net_adaptation = positive_emotion + cognitive_flexibility + exploratory_behavior + &
      affiliative_behavior + social_support + resilience_score + contextual_safety + &
      resource_stock + practice_fit - negative_emotion - stress_arousal

  print *, "Broadening index:", broadening
  print *, "Resource index:", resource
  print *, "Recovery capacity index:", recovery
  print *, "Net adaptation index:", net_adaptation
end program broaden_build_index
