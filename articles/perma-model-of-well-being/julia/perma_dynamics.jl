# PERMA and multidimensional flourishing systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, benefits eligibility, ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "positive_emotion",
    "engagement",
    "relationships",
    "meaning",
    "accomplishment",
    "institutional_support",
    "institutional_barriers",
    "autonomy_support",
    "fairness",
    "psychological_safety",
    "access",
    "workload_strain",
    "life_satisfaction",
    "flourishing"
]

state = [0.62, 0.64, 0.65, 0.63, 0.64, 0.65, 0.38, 0.64, 0.63, 0.65, 0.64, 0.41, 0.63, 0.64]

A = [
    0.84 0.04 0.04 0.04 0.04 0.05 -0.04 0.04 0.04 0.04 0.04 -0.04 0.06 0.06;
    0.04 0.84 0.04 0.05 0.05 0.05 -0.04 0.05 0.04 0.04 0.04 -0.05 0.05 0.06;
    0.04 0.04 0.84 0.05 0.04 0.06 -0.05 0.04 0.05 0.06 0.05 -0.04 0.06 0.07;
    0.04 0.05 0.05 0.84 0.05 0.05 -0.04 0.05 0.05 0.04 0.04 -0.04 0.06 0.07;
    0.04 0.05 0.04 0.05 0.84 0.05 -0.04 0.05 0.05 0.04 0.04 -0.05 0.05 0.06;
    0.05 0.05 0.06 0.05 0.05 0.84 -0.07 0.06 0.06 0.06 0.06 -0.06 0.06 0.07;
    -0.04 -0.04 -0.05 -0.04 -0.04 -0.07 0.82 -0.05 -0.05 -0.05 -0.05 0.07 -0.06 -0.07;
    0.04 0.05 0.04 0.05 0.05 0.06 -0.05 0.84 0.05 0.05 0.05 -0.05 0.05 0.06;
    0.04 0.04 0.05 0.05 0.05 0.06 -0.05 0.05 0.84 0.06 0.05 -0.05 0.05 0.06;
    0.04 0.04 0.06 0.04 0.04 0.06 -0.05 0.05 0.06 0.84 0.05 -0.05 0.05 0.06;
    0.04 0.04 0.05 0.04 0.04 0.06 -0.05 0.05 0.05 0.05 0.84 -0.05 0.05 0.06;
    -0.04 -0.05 -0.04 -0.04 -0.05 -0.06 0.07 -0.05 -0.05 -0.05 -0.05 0.82 -0.06 -0.07;
    0.06 0.05 0.06 0.06 0.05 0.06 -0.06 0.05 0.05 0.05 0.05 -0.06 0.84 0.07;
    0.06 0.06 0.07 0.07 0.06 0.07 -0.07 0.06 0.06 0.06 0.06 -0.07 0.07 0.84
]

function step_system(state, A; development_boost=zeros(length(state)), institutional_shock=zeros(length(state)))
    next_state = A * state + development_boost + institutional_shock
    return clamp.(next_state, 0.0, 1.0)
end

function perma_index(state)
    return mean(state[1:5])
end

function perma_balance(state)
    return -var(state[1:5])
end

function institutional_quality(state)
    return state[6] + state[8] + state[9] + state[10] + state[11] - state[7] - state[12]
end

function context_adjusted_flourishing(state)
    return state[14] + state[13] + perma_index(state) + perma_balance(state) + institutional_quality(state)
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    development_boost = zeros(length(state))
    institutional_shock = zeros(length(state))

    if t <= 10
        development_boost[2] = 0.014  # engagement
        development_boost[3] = 0.014  # relationships
        development_boost[4] = 0.014  # meaning
        development_boost[6] = 0.015  # institutional support
    end

    if t == 12
        institutional_shock[7] = 0.09  # institutional barriers
        institutional_shock[12] = 0.08 # workload strain
        institutional_shock[8] = -0.04 # autonomy support
        institutional_shock[14] = -0.04 # flourishing
    end

    if t >= 18 && t <= 26
        development_boost[1] = 0.012  # positive emotion
        development_boost[2] = 0.014  # engagement
        development_boost[4] = 0.014  # meaning
        development_boost[5] = 0.014  # accomplishment
        development_boost[8] = 0.015  # autonomy
        development_boost[9] = 0.014  # fairness
        development_boost[14] = 0.015 # flourishing
    end

    history[t, :] = step_system(history[t - 1, :], A; development_boost=development_boost, institutional_shock=institutional_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

perma_scores = [perma_index(history[t, :]) for t in 1:size(history, 1)]
balance_scores = [perma_balance(history[t, :]) for t in 1:size(history, 1)]
institution_scores = [institutional_quality(history[t, :]) for t in 1:size(history, 1)]
flourishing_scores = [context_adjusted_flourishing(history[t, :]) for t in 1:size(history, 1)]

println("\nMean PERMA index: ", round(mean(perma_scores), digits=3))
println("Final PERMA index: ", round(perma_scores[end], digits=3))
println("Mean PERMA balance: ", round(mean(balance_scores), digits=3))
println("Final PERMA balance: ", round(balance_scores[end], digits=3))
println("Mean institutional quality: ", round(mean(institution_scores), digits=3))
println("Final institutional quality: ", round(institution_scores[end], digits=3))
println("Mean context-adjusted flourishing: ", round(mean(flourishing_scores), digits=3))
println("Final context-adjusted flourishing: ", round(flourishing_scores[end], digits=3))
