program wellbeing_economy_index
  implicit none
  real :: values(11)
  real :: weights(11)
  real :: score

  values = (/ 7.6, 7.5, 7.7, 7.6, 7.8, 7.3, 7.4, 7.5, 7.8, 2.4, 2.9 /)
  weights = (/ 0.12, 0.12, 0.12, 0.11, 0.11, 0.10, 0.10, 0.10, 0.10, -0.06, -0.06 /)

  score = sum(values * weights)

  print *, "Well-being economy index:", score
end program wellbeing_economy_index
