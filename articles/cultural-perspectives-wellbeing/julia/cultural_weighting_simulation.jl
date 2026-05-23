# Cultural weighting simulation for well-being systems.
#
# Synthetic demonstration only. Not for clinical, employment, ranking, or individual assessment use.

using LinearAlgebra
using Statistics
using Random

Random.seed!(42)

domains = [
    "life_satisfaction",
    "social_support",
    "relational_harmony",
    "institutional_trust",
    "income_security",
    "civic_voice",
    "cultural_continuity",
    "place_attachment"
]

values = [6.8, 6.7, 7.0, 6.2, 6.3, 5.9, 7.1, 7.2]

western_weights = [0.18, 0.12, 0.10, 0.12, 0.15, 0.13, 0.10, 0.10]
relational_weights = [0.10, 0.15, 0.18, 0.10, 0.10, 0.10, 0.14, 0.13]
place_based_weights = [0.09, 0.12, 0.14, 0.08, 0.09, 0.10, 0.18, 0.20]

function weighted_index(values, weights)
    return dot(values, weights) / sum(abs.(weights))
end

println("Synthetic cultural well-being index under different weighting traditions:")
println("Western-weighted model: ", round(weighted_index(values, western_weights), digits=3))
println("Relational-weighted model: ", round(weighted_index(values, relational_weights), digits=3))
println("Place-based model: ", round(weighted_index(values, place_based_weights), digits=3))

println("\nDomain contribution under place-based model:")
for (domain, value, weight) in zip(domains, values, place_based_weights)
    println(domain, ": ", round(value * weight, digits=3))
end
