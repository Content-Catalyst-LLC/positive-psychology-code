program public_health_wellbeing_index
  implicit none
  real :: values(11)
  real :: weights(11)
  real :: score

  values = (/ 7.4, 7.6, 7.3, 7.2, 7.5, 7.4, 7.6, 7.3, 7.1, 7.3, 3.0 /)
  weights = (/ 0.11, 0.12, 0.10, 0.10, 0.11, 0.10, 0.09, 0.10, 0.09, 0.10, -0.10 /)

  score = sum(values * weights)

  print *, "Public health well-being index:", score
end program public_health_wellbeing_index
