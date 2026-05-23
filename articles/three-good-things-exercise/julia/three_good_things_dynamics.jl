# Three Good Things reflective-practice dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, crisis-support,
# employment, public-benefits, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "life_satisfaction",
    "depressive_symptoms",
    "gratitude",
    "positive_event_salience",
    "perceived_support",
    "reflection_depth",
    "stress_load",
    "acceptability",
    "context_fit"
]

state = [0.62, 0.48, 0.60, 0.58, 0.61, 0.57, 0.46, 0.65, 0.64]

A = [
    0.82 -0.05 0.05 0.05 0.04 0.04 -0.06 0.03 0.04;
    -0.05 0.82 -0.04 -0.04 -0.04 -0.04 0.07 -0.03 -0.03;
    0.05 -0.04 0.84 0.07 0.06 0.05 -0.05 0.05 0.05;
    0.05 -0.04 0.07 0.84 0.05 0.06 -0.05 0.05 0.05;
    0.04 -0.04 0.06 0.05 0.84 0.04 -0.05 0.04 0.05;
    0.04 -0.04 0.05 0.06 0.04 0.84 -0.04 0.05 0.05;
    -0.06 0.07 -0.05 -0.05 -0.05 -0.04 0.82 -0.04 -0.04;
    0.03 -0.03 0.05 0.05 0.04 0.05 -0.04 0.84 0.06;
    0.04 -0.03 0.05 0.05 0.05 0.05 -0.04 0.06 0.84
]

function step_system(state, A; practice_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = A * state + practice_boost + stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function appreciative_awareness(state)
    return mean(state[[3,4,5,6,8,9]]) - 0.25 * state[7]
end

function net_wellbeing(state)
    return state[1] + state[3] + state[4] + state[5] + state[6] - state[2] - state[7]
end

history = Matrix{Float64}(undef, 21, length(state))
history[1, :] = state

for t in 2:21
    practice_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 8
        practice_boost[3] = 0.035  # gratitude
        practice_boost[4] = 0.035  # positive event salience
        practice_boost[6] = 0.030  # reflection depth
    end

    if t == 10
        stress_shock[7] = 0.08     # stressor load
        stress_shock[2] = 0.05     # distress burden
    end

    if t == 15
        practice_boost[8] = 0.04   # acceptability adaptation
        practice_boost[9] = 0.04   # context fit adaptation
    end

    history[t, :] = step_system(history[t - 1, :], A; practice_boost=practice_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

appreciative_scores = [appreciative_awareness(history[t, :]) for t in 1:size(history, 1)]
net_scores = [net_wellbeing(history[t, :]) for t in 1:size(history, 1)]

println("\nMean appreciative awareness: ", round(mean(appreciative_scores), digits=3))
println("Final appreciative awareness: ", round(appreciative_scores[end], digits=3))
println("Mean net wellbeing: ", round(mean(net_scores), digits=3))
println("Final net wellbeing: ", round(net_scores[end], digits=3))
