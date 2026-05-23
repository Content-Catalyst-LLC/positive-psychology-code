program character_indices
  implicit none
  real :: wisdom, courage, humanity, justice, temperance, transcendence
  real :: signature_strength_use, authenticity_score, contextual_support
  real :: institutional_suppression, strength_overuse_risk, flourishing_score
  real :: virtue_profile, strength_expression, context_adjusted

  wisdom = 7.2
  courage = 7.0
  humanity = 7.5
  justice = 7.2
  temperance = 7.0
  transcendence = 7.4
  signature_strength_use = 7.3
  authenticity_score = 7.4
  contextual_support = 7.2
  institutional_suppression = 2.9
  strength_overuse_risk = 2.6
  flourishing_score = 7.3

  virtue_profile = (wisdom + courage + humanity + justice + temperance + transcendence) / 6.0
  strength_expression = signature_strength_use + authenticity_score + contextual_support - &
      institutional_suppression - strength_overuse_risk
  context_adjusted = flourishing_score + strength_expression + contextual_support - &
      institutional_suppression - strength_overuse_risk

  print *, "Virtue profile mean:", virtue_profile
  print *, "Strength-expression index:", strength_expression
  print *, "Context-adjusted flourishing:", context_adjusted
end program character_indices
