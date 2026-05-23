program subjective_wellbeing_index
  implicit none
  real :: values(7)
  real :: weights(7)
  real :: score

  values = (/ 7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4 /)
  weights = (/ 0.30, 0.25, -0.25, 0.10, 0.08, 0.10, -0.08 /)

  score = sum(values * weights)

  print *, "Subjective well-being index:", score
end program subjective_wellbeing_index
