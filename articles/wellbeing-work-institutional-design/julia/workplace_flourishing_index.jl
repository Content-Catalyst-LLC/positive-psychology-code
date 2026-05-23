values = [7.4, 7.2, 7.0, 7.6, 7.1, 7.3, 6.8, 3.5, 2.8]
weights = [0.15, 0.14, 0.14, 0.14, 0.14, 0.10, 0.09, -0.05, -0.05]

score = dot(values, weights)

println("Workplace flourishing index: $(round(score, digits=3))")
