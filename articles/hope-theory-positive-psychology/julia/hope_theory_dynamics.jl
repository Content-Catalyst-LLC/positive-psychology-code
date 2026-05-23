# Hope Theory goal-pursuit dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, ranking, benefits eligibility, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "agency",
    "pathways",
    "goal_clarity",
    "goal_progress",
    "wellbeing",
    "meaning",
    "stress_load",
    "obstacle_intensity",
    "social_support",
    "resource_access",
    "goal_revision_quality",
    "context_support"
]

state = [0.64, 0.62, 0.66, 0.58, 0.64, 0.67, 0.44, 0.46, 0.66, 0.61, 0.62, 0.64]

A = [
    0.84 0.05 0.04 0.05 0.04 0.05 -0.05 -0.05 0.05 0.04 0.04 0.05;
    0.05 0.84 0.05 0.06 0.04 0.04 -0.04 -0.06 0.04 0.06 0.07 0.06;
    0.04 0.05 0.84 0.05 0.04 0.06 -0.04 -0.04 0.04 0.04 0.05 0.05;
    0.05 0.06 0.05 0.84 0.06 0.05 -0.05 -0.06 0.05 0.05 0.06 0.05;
    0.04 0.04 0.04 0.06 0.84 0.06 -0.06 -0.05 0.05 0.04 0.04 0.05;
    0.05 0.04 0.06 0.05 0.06 0.84 -0.05 -0.04 0.05 0.04 0.05 0.05;
    -0.05 -0.04 -0.04 -0.05 -0.06 -0.05 0.82 0.06 -0.05 -0.04 -0.04 -0.05;
    -0.05 -0.06 -0.04 -0.06 -0.05 -0.04 0.06 0.82 -0.04 -0.06 -0.05 -0.05;
    0.05 0.04 0.04 0.05 0.05 0.05 -0.05 -0.04 0.84 0.05 0.04 0.06;
    0.04 0.06 0.04 0.05 0.04 0.04 -0.04 -0.06 0.05 0.84 0.05 0.06;
    0.04 0.07 0.05 0.06 0.04 0.05 -0.04 -0.05 0.04 0.05 0.84 0.05;
    0.05 0.06 0.05 0.05 0.05 0.05 -0.05 -0.05 0.06 0.06 0.05 0.84
]

function step_system(state, A; hope_boost=zeros(length(state)), obstacle_shock=zeros(length(state)))
    next_state = A * state + hope_boost + obstacle_shock
    return clamp.(next_state, 0.0, 1.0)
end

function hope_index(state)
    return mean(state[[1, 2]])
end

function context_support_index(state)
    return mean(state[[9, 10, 12]])
end

function net_pathway_context(state)
    return state[2] + context_support_index(state) + state[11] - state[8]
end

function net_future_orientation(state)
    return state[1] + state[2] + state[3] + state[4] + state[6] + context_support_index(state) - state[7] - state[8]
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    hope_boost = zeros(length(state))
    obstacle_shock = zeros(length(state))

    if t <= 10
        hope_boost[1] = 0.020  # agency
        hope_boost[2] = 0.020  # pathways
        hope_boost[3] = 0.015  # goal clarity
        hope_boost[9] = 0.015  # social support
        hope_boost[10] = 0.015 # resource access
    end

    if t == 12
        obstacle_shock[8] = 0.08  # obstacle intensity
        obstacle_shock[7] = 0.06  # stress load
        obstacle_shock[4] = -0.04 # goal progress disruption
    end

    if t == 18
        hope_boost[2] = 0.06   # pathway expansion
        hope_boost[10] = 0.05  # resource access increase
        hope_boost[11] = 0.05  # goal revision quality
        hope_boost[12] = 0.05  # context support
    end

    history[t, :] = step_system(history[t - 1, :], A; hope_boost=hope_boost, obstacle_shock=obstacle_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

hope_scores = [hope_index(history[t, :]) for t in 1:size(history, 1)]
pathway_context_scores = [net_pathway_context(history[t, :]) for t in 1:size(history, 1)]
future_orientation_scores = [net_future_orientation(history[t, :]) for t in 1:size(history, 1)]

println("\nMean hope index: ", round(mean(hope_scores), digits=3))
println("Final hope index: ", round(hope_scores[end], digits=3))
println("Mean net pathway context: ", round(mean(pathway_context_scores), digits=3))
println("Final net pathway context: ", round(pathway_context_scores[end], digits=3))
println("Mean net future orientation: ", round(mean(future_orientation_scores), digits=3))
println("Final net future orientation: ", round(future_orientation_scores[end], digits=3))
