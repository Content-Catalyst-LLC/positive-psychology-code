program hedonic_eudaimonic_index
  implicit none
  real :: hedonic
  real :: eudaimonic
  real :: integrated
  real :: eud_values(6)

  eud_values = (/ 7.3, 7.4, 7.5, 7.7, 7.4, 7.3 /)

  hedonic = 7.6 + 7.4 - 2.5
  eudaimonic = sum(eud_values) / 6.0
  integrated = 0.40 * hedonic + 0.45 * eudaimonic + 0.20 * 7.5 - 0.20 * 2.8

  print *, "Hedonic index:", hedonic
  print *, "Eudaimonic index:", eudaimonic
  print *, "Integrated flourishing index:", integrated
end program hedonic_eudaimonic_index
