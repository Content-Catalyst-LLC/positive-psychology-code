program sustainable_flourishing_index
  implicit none
  real :: values(10)
  real :: weights(10)
  real :: score

  values = (/ 7.8, 7.7, 7.6, 7.5, 7.7, 7.3, 7.6, 7.4, 7.8, 2.4 /)
  weights = (/ 0.11, 0.11, 0.10, 0.11, 0.12, 0.12, 0.11, 0.10, 0.10, -0.08 /)

  score = sum(values * weights)

  print *, "Sustainable flourishing index:", score
end program sustainable_flourishing_index
