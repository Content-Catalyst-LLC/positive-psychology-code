program explanatory_indices
  implicit none
  real :: neg_stability, neg_globality, neg_personalization
  real :: pos_stability, pos_globality, pos_internal_effort
  real :: setback_intensity, controllability_score, agency_score, support_score
  real :: persistence_score, hope_score, wellbeing_score, distress_score
  real :: burden, positive_integration, context_agency, resilient_persistence

  neg_stability = 3.8
  neg_globality = 3.6
  neg_personalization = 3.7
  pos_stability = 6.6
  pos_globality = 6.4
  pos_internal_effort = 6.5
  setback_intensity = 4.3
  controllability_score = 6.5
  agency_score = 6.6
  support_score = 6.7
  persistence_score = 6.6
  hope_score = 6.7
  wellbeing_score = 6.6
  distress_score = 4.0

  burden = (neg_stability + neg_globality + neg_personalization) / 3.0
  positive_integration = (pos_stability + pos_globality + pos_internal_effort) / 3.0
  context_agency = agency_score + support_score + controllability_score - setback_intensity - burden
  resilient_persistence = persistence_score + hope_score + agency_score + support_score + &
      positive_integration - setback_intensity - burden - distress_score

  print *, "Explanatory burden:", burden
  print *, "Positive-event integration:", positive_integration
  print *, "Context-adjusted agency:", context_agency
  print *, "Resilient persistence index:", resilient_persistence
end program explanatory_indices
