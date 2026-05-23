program virtue_index
  implicit none
  real :: virtues(6) = (/4.2, 3.8, 4.4, 4.1, 3.7, 4.0/)
  real :: flourishing(4) = (/4.1, 4.3, 3.9, 4.0/)

  print '(A, F6.3)', 'Mean virtue-domain score: ', sum(virtues) / size(virtues)
  print '(A, F6.3)', 'Mean flourishing score: ', sum(flourishing) / size(flourishing)
end program virtue_index
