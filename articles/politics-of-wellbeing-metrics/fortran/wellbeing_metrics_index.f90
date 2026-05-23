program wellbeing_metrics_index
  implicit none
  real :: values(9)
  real :: weights(9)
  real :: score

  values = (/ 7.4, 7.3, 6.9, 7.0, 6.8, 7.2, 7.5, 6.9, 3.0 /)
  weights = (/ 0.16, 0.14, 0.14, 0.14, 0.10, 0.10, 0.10, 0.08, -0.08 /)

  score = sum(values * weights)

  print *, "Public well-being index:", score
end program wellbeing_metrics_index
