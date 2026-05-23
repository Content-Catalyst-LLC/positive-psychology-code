program future_wellbeing_index
  implicit none
  real :: values(10)
  real :: weights(10)
  real :: score

  values = (/ 7.4, 7.6, 7.0, 7.2, 6.9, 7.3, 7.1, 7.0, 6.9, 3.2 /)
  weights = (/ 0.13, 0.13, 0.12, 0.12, 0.12, 0.13, 0.10, 0.10, 0.10, -0.05 /)

  score = sum(values * weights)

  print *, "Future well-being index:", score
end program future_wellbeing_index
