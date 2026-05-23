# Positive psychology intervention mechanism dynamics scaffold.
# Synthetic demonstration only.

using Statistics
using Random

Random.seed!(42)

domains = [
    "wellbeing_score",
    "depressive_symptoms",
    "gratitude",
    "strengths_use",
    "hope",
    "meaning",
    "social_support",
    "adherence",
    "intervention_fit",
    "stress_load",
    "acceptability",
    "context_fit"
]

state = [0.62, 0.48, 0.60, 0.60, 0.61, 0.62, 0.63, 0.70, 0.66, 0.44, 0.68, 0.66]

function step_system(state; practice_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = 0.88 .* state .+ practice_boost .+ stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function mechanism_index(state)
    return mean(state[[3,4,5,6,7]])
end

function net_wellbeing(state)
    return state[1] + mean(state[[3,4,5,6,7]]) + state[9] - state[2] - state[10]
end

history = Matrix{Float64}(undef, 24, length(state))
history[1, :] = state

for t in 2:24
    practice_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 10
        practice_boost[3] = 0.020
        practice_boost[4] = 0.020
        practice_boost[5] = 0.020
        practice_boost[6] = 0.020
        practice_boost[7] = 0.015
        practice_boost[8] = 0.015
    end

    if t == 12
        stress_shock[10] = 0.08
        stress_shock[2] = 0.05
    end

    if t == 16
        practice_boost[9] = 0.05
        practice_boost[12] = 0.05
        practice_boost[11] = 0.04
    end

    history[t, :] = step_system(history[t - 1, :]; practice_boost=practice_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

mechanism_scores = [mechanism_index(history[t, :]) for t in 1:size(history, 1)]
net_scores = [net_wellbeing(history[t, :]) for t in 1:size(history, 1)]

println("\nMean mechanism index: ", round(mean(mechanism_scores), digits=3))
println("Final mechanism index: ", round(mechanism_scores[end], digits=3))
println("Mean net wellbeing: ", round(mean(net_scores), digits=3))
println("Final net wellbeing: ", round(net_scores[end], digits=3))
