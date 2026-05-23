program workplace_flourishing_index
  implicit none
  real :: values(9)
  real :: weights(9)
  real :: score

  values = (/ 7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8 /)
  weights = (/ 0.15, 0.14, 0.14, 0.14, 0.14, 0.10, 0.09, -0.05, -0.05 /)

  score = sum(values * weights)

  print *, "Workplace flourishing index:", score
end program workplace_flourishing_index
