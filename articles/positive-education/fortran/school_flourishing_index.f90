program school_flourishing_index
  implicit none
  real :: academic_score, engagement, belonging, resilience, life_satisfaction
  real :: school_climate, teacher_support, purpose_learning, stress_load
  real :: exclusion_exposure, access_support, student_voice, score

  academic_score = 82.0
  engagement = 7.3
  belonging = 7.5
  resilience = 7.2
  life_satisfaction = 7.4
  school_climate = 7.6
  teacher_support = 7.7
  purpose_learning = 7.3
  stress_load = 2.9
  exclusion_exposure = 2.0
  access_support = 7.5
  student_voice = 7.2

  score = 0.20 * academic_score + &
          0.18 * engagement + &
          0.18 * ((belonging + teacher_support) / 2.0) + &
          0.18 * ((resilience + life_satisfaction + purpose_learning) / 3.0) + &
          0.20 * ((school_climate + access_support + student_voice) / 3.0) - &
          0.14 * stress_load - &
          0.16 * exclusion_exposure

  print *, "School flourishing index:", score
end program school_flourishing_index
