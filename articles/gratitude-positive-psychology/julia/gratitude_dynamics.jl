# Gratitude, support, and well-being dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, crisis-support,
# employment, school disciplinary, public-benefits, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "gratitude",
    "life_satisfaction",
    "perceived_support",
    "resilience",
    "stress_load",
    "depressive_symptoms",
    "reflection_depth",
    "gratitude_expression",
    "intervention_fit",
    "relationship_quality",
    "social_trust"
]

state = [0.62, 0.63, 0.65, 0.62, 0.45, 0.47, 0.58, 0.59, 0.62, 0.64, 0.61]

A = [
    0.84 0.05 0.06 0.04 -0.05 -0.04 0.06 0.06 0.05 0.05 0.05;
    0.05 0.82 0.05 0.05 -0.06 -0.05 0.04 0.04 0.04 0.05 0.04;
    0.06 0.05 0.84 0.04 -0.05 -0.04 0.04 0.06 0.05 0.07 0.06;
    0.04 0.05 0.04 0.83 -0.05 -0.05 0.04 0.04 0.04 0.04 0.04;
    -0.05 -0.06 -0.05 -0.05 0.82 0.07 -0.04 -0.04 -0.04 -0.05 -0.04;
    -0.04 -0.05 -0.04 -0.05 0.07 0.82 -0.04 -0.04 -0.03 -0.04 -0.04;
    0.06 0.04 0.04 0.04 -0.04 -0.04 0.84 0.06 0.05 0.04 0.04;
    0.06 0.04 0.06 0.04 -0.04 -0.04 0.06 0.84 0.05 0.07 0.06;
    0.05 0.04 0.05 0.04 -0.04 -0.03 0.05 0.05 0.84 0.05 0.05;
    0.05 0.05 0.07 0.04 -0.05 -0.04 0.04 0.07 0.05 0.84 0.07;
    0.05 0.04 0.06 0.04 -0.04 -0.04 0.04 0.06 0.05 0.07 0.84
]

function step_system(state, A; gratitude_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = A * state + gratitude_boost + stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function appreciative_orientation(state)
    return mean(state[[1,3,7,8,9,10,11]]) - 0.25 * state[5]
end

function net_wellbeing(state)
    return state[2] + state[1] + state[3] + state[4] + state[7] + state[8] + state[10] + state[11] - state[5] - state[6]
end

history = Matrix{Float64}(undef, 24, length(state))
history[1, :] = state

for t in 2:24
    gratitude_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 10
        gratitude_boost[1] = 0.025  # gratitude
        gratitude_boost[7] = 0.020  # reflection depth
        gratitude_boost[8] = 0.020  # gratitude expression
    end

    if t == 12
        stress_shock[5] = 0.08      # stress load
        stress_shock[6] = 0.05      # depressive-symptom burden
    end

    if t == 16
        gratitude_boost[3] = 0.04   # perceived support
        gratitude_boost[10] = 0.04  # relationship quality
        gratitude_boost[11] = 0.04  # social trust
        gratitude_boost[9] = 0.03   # fit/context adaptation
    end

    history[t, :] = step_system(history[t - 1, :], A; gratitude_boost=gratitude_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

appreciative_scores = [appreciative_orientation(history[t, :]) for t in 1:size(history, 1)]
net_scores = [net_wellbeing(history[t, :]) for t in 1:size(history, 1)]

println("\nMean appreciative orientation: ", round(mean(appreciative_scores), digits=3))
println("Final appreciative orientation: ", round(appreciative_scores[end], digits=3))
println("Mean net wellbeing: ", round(mean(net_scores), digits=3))
println("Final net wellbeing: ", round(net_scores[end], digits=3))
