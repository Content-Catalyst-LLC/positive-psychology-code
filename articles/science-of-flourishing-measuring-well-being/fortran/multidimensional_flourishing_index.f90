program multidimensional_flourishing_index
  implicit none
  real :: hedonic
  real :: eudaimonic
  real :: integrated
  real :: eud_values(3)

  eud_values = (/ 7.5, 7.4, 7.3 /)

  hedonic = 7.6 + 7.4 - 2.5
  eudaimonic = sum(eud_values) / 3.0
  integrated = 0.25 * hedonic + 0.25 * eudaimonic + 0.15 * 7.7 + 0.15 * 7.4 + 0.15 * 7.5 + 0.15 * 7.5 - 0.15 * 2.8

  print *, "Hedonic index:", hedonic
  print *, "Eudaimonic index:", eudaimonic
  print *, "Integrated flourishing index:", integrated
end program multidimensional_flourishing_index
