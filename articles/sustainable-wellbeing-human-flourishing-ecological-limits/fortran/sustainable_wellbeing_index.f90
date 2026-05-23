program sustainable_wellbeing_index
  implicit none
  real :: values(9)
  real :: weights(9)
  real :: score

  values = (/ 7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8 /)
  weights = (/ 0.16, 0.14, 0.12, 0.12, 0.14, 0.14, -0.04, -0.04, 0.10 /)

  score = sum(values * weights)

  print *, "Sustainable well-being index:", score
end program sustainable_wellbeing_index
