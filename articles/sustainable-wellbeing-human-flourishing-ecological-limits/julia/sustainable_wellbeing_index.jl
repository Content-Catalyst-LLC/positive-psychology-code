values = [7.4, 7.8, 7.0, 6.9, 7.2, 7.1, 4.0, 3.0, 6.8]
weights = [0.16, 0.14, 0.12, 0.12, 0.14, 0.14, -0.04, -0.04, 0.10]

score = dot(values, weights)

println("Sustainable well-being index: $(round(score, digits=3))")
