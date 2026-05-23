program meaning_indices
  implicit none
  real :: meaning_presence, meaning_search, purpose_score, coherence_score
  real :: significance_score, belonging_score, value_alignment, institutional_support
  real :: wellbeing_score, goal_persistence, stress_load, alienation_score
  real :: identity_integration, context_quality
  real :: meaning_system, context_adjusted, directed_life, search_context

  meaning_presence = 7.1
  meaning_search = 4.9
  purpose_score = 7.2
  coherence_score = 6.9
  significance_score = 7.1
  belonging_score = 7.2
  value_alignment = 7.0
  institutional_support = 6.8
  wellbeing_score = 7.1
  goal_persistence = 7.2
  stress_load = 3.7
  alienation_score = 3.1
  identity_integration = 6.9
  context_quality = 7.0

  meaning_system = (meaning_presence + purpose_score + coherence_score + significance_score + &
       belonging_score + value_alignment + identity_integration) / 7.0
  context_adjusted = meaning_system + institutional_support + context_quality - stress_load - alienation_score
  directed_life = purpose_score + goal_persistence + value_alignment + institutional_support - stress_load
  search_context = meaning_search + stress_load + alienation_score - meaning_presence - coherence_score

  print *, "Meaning system index:", meaning_system
  print *, "Context-adjusted meaning:", context_adjusted
  print *, "Directed-life index:", directed_life
  print *, "Search-context index:", search_context
end program meaning_indices
