program sdt_indices
  implicit none
  real :: autonomy_support, competence_support, relatedness_support
  real :: need_frustration, controlling_pressure
  real :: autonomous_motivation, controlled_motivation, internalization
  real :: wellbeing_score, vitality, stress_load, climate_quality
  real :: need_support, need_balance, motivational_quality, net_sdt_wellbeing

  autonomy_support = 7.4
  competence_support = 7.3
  relatedness_support = 7.5
  need_frustration = 2.0
  controlling_pressure = 2.4
  autonomous_motivation = 7.3
  controlled_motivation = 2.8
  internalization = 6.9
  wellbeing_score = 7.4
  vitality = 7.3
  stress_load = 2.9
  climate_quality = 7.6

  need_support = (autonomy_support + competence_support + relatedness_support) / 3.0
  need_balance = need_support - need_frustration - controlling_pressure
  motivational_quality = autonomous_motivation + internalization - controlled_motivation
  net_sdt_wellbeing = wellbeing_score + vitality + autonomous_motivation + internalization + &
      need_support - controlled_motivation - stress_load - need_frustration - controlling_pressure

  print *, "Need support index:", need_support
  print *, "Need balance index:", need_balance
  print *, "Motivational quality index:", motivational_quality
  print *, "Net SDT wellbeing index:", net_sdt_wellbeing
end program sdt_indices
