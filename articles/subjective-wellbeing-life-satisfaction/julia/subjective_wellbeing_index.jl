values = [7.4, 7.2, 2.9, 7.0, 6.9, 7.6, 3.4]
weights = [0.30, 0.25, -0.25, 0.10, 0.08, 0.10, -0.08]

score = dot(values, weights)

println("Subjective well-being index: $(round(score, digits=3))")
