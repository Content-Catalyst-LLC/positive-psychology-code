program cultural_wellbeing_index
  implicit none
  real :: values(10)
  real :: weights(10)
  real :: score

  values = (/ 6.9, 7.0, 7.4, 6.7, 6.5, 6.4, 7.4, 7.0, 6.0, 7.8 /)
  weights = (/ 0.12, 0.11, 0.12, 0.10, 0.10, 0.09, 0.12, 0.12, 0.06, 0.06 /)

  score = sum(values * weights)

  print *, "Cultural well-being index:", score
end program cultural_wellbeing_index
