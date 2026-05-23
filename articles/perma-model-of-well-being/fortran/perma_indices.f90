program perma_indices
  implicit none
  real :: positive_emotion, engagement, relationships, meaning, accomplishment
  real :: flourishing_score, life_satisfaction, institutional_support, institutional_barriers
  real :: autonomy_support, fairness_score, psychological_safety, access_score, workload_strain
  real :: perma, institutional_quality, context_adjusted

  positive_emotion = 6.9
  engagement = 7.1
  relationships = 7.2
  meaning = 7.0
  accomplishment = 7.1
  flourishing_score = 7.1
  life_satisfaction = 7.0
  institutional_support = 7.2
  institutional_barriers = 3.1
  autonomy_support = 7.1
  fairness_score = 7.0
  psychological_safety = 7.2
  access_score = 7.1
  workload_strain = 3.4

  perma = (positive_emotion + engagement + relationships + meaning + accomplishment) / 5.0
  institutional_quality = institutional_support + autonomy_support + fairness_score + &
      psychological_safety + access_score - institutional_barriers - workload_strain
  context_adjusted = flourishing_score + life_satisfaction + perma + institutional_quality

  print *, "PERMA index:", perma
  print *, "Institutional quality:", institutional_quality
  print *, "Context-adjusted flourishing:", context_adjusted
end program perma_indices
