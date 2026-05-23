program critique_sensitive_flourishing_index
  implicit none
  real :: values(10)
  real :: weights(10)
  real :: score

  values = (/ 7.4, 7.6, 7.3, 7.5, 7.6, 7.4, 7.3, 7.2, 2.2, 2.8 /)
  weights = (/ 0.13, 0.13, 0.10, 0.11, 0.11, 0.11, 0.09, 0.09, -0.08, -0.08 /)

  score = sum(values * weights)

  print *, "Critique-sensitive flourishing index:", score
end program critique_sensitive_flourishing_index
