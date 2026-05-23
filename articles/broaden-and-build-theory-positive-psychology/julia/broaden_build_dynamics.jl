# Broaden-and-Build Theory dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, crisis-support,
# employment, school disciplinary, public-benefits, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "positive_emotion",
    "negative_emotion",
    "cognitive_flexibility",
    "exploratory_behavior",
    "affiliative_behavior",
    "social_support",
    "resilience",
    "stress_arousal",
    "contextual_safety",
    "resource_stock",
    "practice_fit"
]

state = [0.62, 0.45, 0.61, 0.60, 0.62, 0.64, 0.61, 0.44, 0.63, 0.62, 0.64]

A = [
    0.84 -0.05 0.05 0.05 0.05 0.05 0.04 -0.05 0.05 0.04 0.05;
    -0.05 0.82 -0.04 -0.04 -0.04 -0.04 -0.04 0.07 -0.04 -0.03 -0.03;
    0.05 -0.04 0.84 0.06 0.05 0.04 0.04 -0.04 0.06 0.05 0.04;
    0.05 -0.04 0.06 0.84 0.05 0.04 0.04 -0.04 0.06 0.05 0.04;
    0.05 -0.04 0.05 0.05 0.84 0.06 0.04 -0.04 0.06 0.05 0.04;
    0.05 -0.04 0.04 0.04 0.06 0.84 0.05 -0.05 0.06 0.06 0.05;
    0.04 -0.04 0.04 0.04 0.04 0.05 0.84 -0.05 0.05 0.06 0.05;
    -0.05 0.07 -0.04 -0.04 -0.04 -0.05 -0.05 0.82 -0.05 -0.04 -0.04;
    0.05 -0.04 0.06 0.06 0.06 0.06 0.05 -0.05 0.84 0.06 0.06;
    0.04 -0.03 0.05 0.05 0.05 0.06 0.06 -0.04 0.06 0.84 0.05;
    0.05 -0.03 0.04 0.04 0.04 0.05 0.05 -0.04 0.06 0.05 0.84
]

function step_system(state, A; positive_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = A * state + positive_boost + stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function broadening_index(state)
    return mean(state[[1,3,4,5,9]]) - 0.25 * state[2]
end

function resource_index(state)
    return mean(state[[6,7,9,10,11]])
end

function recovery_capacity(state)
    return mean(state[[1,6,7,9]]) - 0.25 * state[2] - 0.25 * state[8]
end

function net_adaptation(state)
    return state[1] + state[3] + state[4] + state[5] + state[6] + state[7] + state[9] + state[10] + state[11] - state[2] - state[8]
end

history = Matrix{Float64}(undef, 28, length(state))
history[1, :] = state

for t in 2:28
    positive_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 10
        positive_boost[1] = 0.025  # positive emotion
        positive_boost[3] = 0.020  # cognitive flexibility
        positive_boost[4] = 0.020  # exploratory behavior
        positive_boost[5] = 0.020  # affiliative behavior
    end

    if t == 12
        stress_shock[2] = 0.07     # negative emotion
        stress_shock[8] = 0.08     # stress arousal
    end

    if t == 17
        positive_boost[6] = 0.04   # social support
        positive_boost[9] = 0.04   # contextual safety
        positive_boost[10] = 0.04  # resource stock
        positive_boost[11] = 0.03  # practice fit
    end

    history[t, :] = step_system(history[t - 1, :], A; positive_boost=positive_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

broadening_scores = [broadening_index(history[t, :]) for t in 1:size(history, 1)]
resource_scores = [resource_index(history[t, :]) for t in 1:size(history, 1)]
recovery_scores = [recovery_capacity(history[t, :]) for t in 1:size(history, 1)]
net_scores = [net_adaptation(history[t, :]) for t in 1:size(history, 1)]

println("\nMean broadening index: ", round(mean(broadening_scores), digits=3))
println("Final broadening index: ", round(broadening_scores[end], digits=3))
println("Mean resource index: ", round(mean(resource_scores), digits=3))
println("Final resource index: ", round(resource_scores[end], digits=3))
println("Mean recovery capacity: ", round(mean(recovery_scores), digits=3))
println("Final recovery capacity: ", round(recovery_scores[end], digits=3))
println("Mean net adaptation: ", round(mean(net_scores), digits=3))
println("Final net adaptation: ", round(net_scores[end], digits=3))
