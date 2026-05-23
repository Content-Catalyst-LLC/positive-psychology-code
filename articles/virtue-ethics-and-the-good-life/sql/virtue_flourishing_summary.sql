SELECT
  wave,
  ROUND(AVG(flourishing), 3) AS avg_flourishing,
  ROUND(AVG(virtue_index), 3) AS avg_virtue_index,
  ROUND(AVG(reflective_judgment), 3) AS avg_practical_wisdom_proxy,
  ROUND(AVG(institutional_support), 3) AS avg_institutional_support,
  ROUND(AVG(stress_load), 3) AS avg_stress_load,
  COUNT(*) AS n_observations
FROM virtue_flourishing_panel
GROUP BY wave
ORDER BY wave;
