program ptg_indices
  implicit none
  real :: ptg_score, wellbeing_score, distress_score
  real :: meaning_making, restored_agency, narrative_integration
  real :: social_support, context_support
  real :: deliberate_rumination, intrusive_rumination, ongoing_stress
  real :: perceived_growth, corroborated_growth
  real :: integration, reflection_balance, growth_distress_balance, growth_alignment

  ptg_score = 6.88
  wellbeing_score = 6.8
  distress_score = 5.6
  meaning_making = 6.9
  restored_agency = 6.8
  narrative_integration = 6.8
  social_support = 7.1
  context_support = 6.9
  deliberate_rumination = 6.7
  intrusive_rumination = 5.3
  ongoing_stress = 4.9
  perceived_growth = 7.1
  corroborated_growth = 6.6

  integration = (meaning_making + restored_agency + narrative_integration + social_support + context_support) / 5.0
  reflection_balance = deliberate_rumination - intrusive_rumination
  growth_distress_balance = ptg_score + wellbeing_score + integration - distress_score - ongoing_stress
  growth_alignment = perceived_growth + corroborated_growth - abs(perceived_growth - corroborated_growth)

  print *, "Integration index:", integration
  print *, "Reflection balance:", reflection_balance
  print *, "Growth-distress balance:", growth_distress_balance
  print *, "Growth alignment:", growth_alignment
end program ptg_indices
