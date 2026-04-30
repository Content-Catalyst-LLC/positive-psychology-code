program resilience_recovery
  implicit none

  integer :: t
  real :: flourishing
  real, parameter :: baseline = 0.75
  real, parameter :: recovery = 0.12
  real, parameter :: support = 0.20
  real, parameter :: strain = 0.08

  flourishing = 0.40

  print *, "Time", "Flourishing"

  do t = 1, 12
     flourishing = flourishing + recovery * (baseline - flourishing) + support - strain
     if (flourishing > 1.0) flourishing = 1.0
     if (flourishing < 0.0) flourishing = 0.0
     print *, t, flourishing
  end do

end program resilience_recovery
