program hope_indices
  implicit none
  real :: agency_score, pathways_score, goal_clarity, goal_progress
  real :: wellbeing_score, meaning_score, stress_load, obstacle_intensity
  real :: social_support, resource_access, goal_revision_quality, context_support
  real :: hope, context_support_index, net_pathway_context, net_future_orientation

  agency_score = 7.1
  pathways_score = 7.0
  goal_clarity = 7.3
  goal_progress = 6.8
  wellbeing_score = 7.1
  meaning_score = 7.4
  stress_load = 3.5
  obstacle_intensity = 3.7
  social_support = 7.2
  resource_access = 6.8
  goal_revision_quality = 6.6
  context_support = 7.0

  hope = (agency_score + pathways_score) / 2.0
  context_support_index = (social_support + resource_access + context_support) / 3.0
  net_pathway_context = pathways_score + context_support_index + goal_revision_quality - obstacle_intensity
  net_future_orientation = agency_score + pathways_score + goal_clarity + goal_progress + &
      meaning_score + context_support_index - stress_load - obstacle_intensity

  print *, "Hope index:", hope
  print *, "Context support index:", context_support_index
  print *, "Net pathway context:", net_pathway_context
  print *, "Net future orientation:", net_future_orientation
end program hope_indices
