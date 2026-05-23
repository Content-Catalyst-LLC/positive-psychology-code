program flow_indices
  implicit none
  real :: challenge_level, skill_level, attention_focus, feedback_quality, goal_clarity
  real :: task_meaning, autonomy_support, distraction_load, interruption_count
  real :: flow_score, performance_score, learning_gain, fatigue_score, recovery_quality, wellbeing_score
  real :: balance, attention_ecology, engagement_context, sustainable_flow

  challenge_level = 7.1
  skill_level = 7.0
  attention_focus = 7.3
  feedback_quality = 7.1
  goal_clarity = 7.4
  task_meaning = 7.4
  autonomy_support = 7.2
  distraction_load = 3.0
  interruption_count = 1.0
  flow_score = 7.2
  performance_score = 7.3
  learning_gain = 0.39
  fatigue_score = 3.2
  recovery_quality = 7.0
  wellbeing_score = 7.2

  balance = -abs(challenge_level - skill_level)
  attention_ecology = attention_focus + feedback_quality + goal_clarity - distraction_load - interruption_count
  engagement_context = balance + attention_focus + feedback_quality + goal_clarity + &
      task_meaning + autonomy_support - distraction_load - interruption_count
  sustainable_flow = flow_score + task_meaning + autonomy_support + recovery_quality - &
      fatigue_score - distraction_load

  print *, "Challenge-skill balance:", balance
  print *, "Attentional ecology:", attention_ecology
  print *, "Deep engagement context:", engagement_context
  print *, "Sustainable flow index:", sustainable_flow
end program flow_indices
