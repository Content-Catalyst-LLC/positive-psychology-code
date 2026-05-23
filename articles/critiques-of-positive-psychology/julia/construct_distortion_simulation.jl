# Construct distortion simulation for critiques of positive psychology.
#
# Synthetic demonstration only. Not for clinical, employment, public-benefits,
# or individual assessment use.

using Statistics
using Random

Random.seed!(42)

constructs = [
    "resilience",
    "gratitude",
    "strengths",
    "optimism",
    "purpose"
]

# Applied uptake rises when constructs move into corporate, wellness, and public markets.
applied_uptake = [0.75, 0.82, 0.78, 0.70, 0.68]

# Retained nuance falls when simplified claims, branding, or performance incentives dominate.
retained_nuance = [0.45, 0.38, 0.50, 0.52, 0.55]

# Institutional accountability, privacy safeguards, and cultural validity reduce risk.
accountability = [0.40, 0.34, 0.42, 0.48, 0.50]
privacy = [0.42, 0.35, 0.44, 0.50, 0.48]
cultural_validity = [0.46, 0.40, 0.50, 0.52, 0.54]

function distortion_risk(uptake, nuance, accountability, privacy, cultural_validity)
    risk = 0.35 * uptake +
           0.30 * (1.0 - nuance) +
           0.15 * (1.0 - accountability) +
           0.10 * (1.0 - privacy) +
           0.10 * (1.0 - cultural_validity)

    return clamp(risk, 0.0, 1.0)
end

println("Synthetic construct-distortion risk:")
for i in eachindex(constructs)
    risk = distortion_risk(
        applied_uptake[i],
        retained_nuance[i],
        accountability[i],
        privacy[i],
        cultural_validity[i]
    )
    println(constructs[i], ": ", round(risk, digits=3))
end

println("\nMean risk: ", round(mean([
    distortion_risk(applied_uptake[i], retained_nuance[i], accountability[i], privacy[i], cultural_validity[i])
    for i in eachindex(constructs)
]), digits=3))
