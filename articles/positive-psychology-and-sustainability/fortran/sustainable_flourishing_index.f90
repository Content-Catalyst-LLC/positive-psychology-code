program sustainable_flourishing_index
  implicit none
  real :: values(15)
  real :: weights(15)
  real :: score

  values = (/ 7.4, 7.3, 7.2, 7.3, 7.4, 7.3, 7.5, 7.4, 7.1, 7.5, 7.2, 7.3, 2.9, 3.0, 2.7 /)
  weights = (/ 0.09, 0.09, 0.08, 0.08, 0.08, 0.07, 0.09, 0.08, 0.09, 0.08, 0.08, 0.08, -0.06, -0.06, -0.06 /)

  score = sum(values * weights)

  print *, "Sustainable flourishing index:", score
end program sustainable_flourishing_index
