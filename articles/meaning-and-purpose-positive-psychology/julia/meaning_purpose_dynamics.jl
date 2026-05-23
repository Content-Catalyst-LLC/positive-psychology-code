# Meaning and purpose systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, benefits eligibility, ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "meaning_presence",
    "meaning_search",
    "purpose",
    "coherence",
    "significance",
    "belonging",
    "value_alignment",
    "institutional_support",
    "wellbeing",
    "goal_persistence",
    "stress_load",
    "alienation",
    "identity_integration",
    "context_quality"
]

state = [0.63, 0.57, 0.64, 0.61, 0.63, 0.64, 0.62, 0.60, 0.63, 0.64, 0.45, 0.39, 0.61, 0.62]

A = [
    0.84 -0.04 0.06 0.07 0.06 0.05 0.06 0.04 0.06 0.05 -0.05 -0.06 0.07 0.05;
    -0.04 0.82 -0.03 -0.05 -0.04 -0.03 -0.04 -0.03 -0.04 -0.03 0.06 0.07 -0.04 -0.03;
    0.06 -0.03 0.84 0.05 0.05 0.04 0.07 0.05 0.05 0.07 -0.04 -0.05 0.05 0.05;
    0.07 -0.05 0.05 0.84 0.05 0.04 0.05 0.04 0.05 0.04 -0.05 -0.06 0.07 0.05;
    0.06 -0.04 0.05 0.05 0.84 0.05 0.06 0.04 0.06 0.05 -0.04 -0.06 0.05 0.05;
    0.05 -0.03 0.04 0.04 0.05 0.84 0.04 0.06 0.05 0.04 -0.04 -0.07 0.05 0.06;
    0.06 -0.04 0.07 0.05 0.06 0.04 0.84 0.05 0.05 0.06 -0.05 -0.06 0.06 0.05;
    0.04 -0.03 0.05 0.04 0.04 0.06 0.05 0.84 0.05 0.05 -0.05 -0.07 0.04 0.07;
    0.06 -0.04 0.05 0.05 0.06 0.05 0.05 0.05 0.84 0.05 -0.06 -0.06 0.05 0.05;
    0.05 -0.03 0.07 0.04 0.05 0.04 0.06 0.05 0.05 0.84 -0.05 -0.05 0.05 0.05;
    -0.05 0.06 -0.04 -0.05 -0.04 -0.04 -0.05 -0.05 -0.06 -0.05 0.82 0.06 -0.05 -0.05;
    -0.06 0.07 -0.05 -0.06 -0.06 -0.07 -0.06 -0.07 -0.06 -0.05 0.06 0.82 -0.06 -0.07;
    0.07 -0.04 0.05 0.07 0.05 0.05 0.06 0.04 0.05 0.05 -0.05 -0.06 0.84 0.05;
    0.05 -0.03 0.05 0.05 0.05 0.06 0.05 0.07 0.05 0.05 -0.05 -0.07 0.05 0.84
]

function step_system(state, A; meaning_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = A * state + meaning_boost + stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function meaning_system_index(state)
    return mean(state[[1, 3, 4, 5, 6, 7, 13]])
end

function context_adjusted_meaning(state)
    return meaning_system_index(state) + state[8] + state[14] - state[11] - state[12]
end

function directed_life_index(state)
    return state[3] + state[10] + state[7] + state[8] - state[11]
end

function search_context_index(state)
    return state[2] + state[11] + state[12] - state[1] - state[4]
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    meaning_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 10
        meaning_boost[3] = 0.018  # purpose
        meaning_boost[4] = 0.016  # coherence
        meaning_boost[6] = 0.016  # belonging
        meaning_boost[8] = 0.014  # institutional support
    end

    if t == 12
        stress_shock[11] = 0.08  # stress
        stress_shock[12] = 0.07  # alienation
        stress_shock[2] = 0.05   # search increases during disruption
    end

    if t == 18
        meaning_boost[1] = 0.05   # meaning presence
        meaning_boost[5] = 0.04   # significance
        meaning_boost[7] = 0.05   # value alignment
        meaning_boost[13] = 0.05  # identity integration
        meaning_boost[14] = 0.05  # context quality
    end

    history[t, :] = step_system(history[t - 1, :], A; meaning_boost=meaning_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

meaning_scores = [meaning_system_index(history[t, :]) for t in 1:size(history, 1)]
context_scores = [context_adjusted_meaning(history[t, :]) for t in 1:size(history, 1)]
directed_scores = [directed_life_index(history[t, :]) for t in 1:size(history, 1)]
search_scores = [search_context_index(history[t, :]) for t in 1:size(history, 1)]

println("\nMean meaning system index: ", round(mean(meaning_scores), digits=3))
println("Final meaning system index: ", round(meaning_scores[end], digits=3))
println("Mean context-adjusted meaning: ", round(mean(context_scores), digits=3))
println("Final context-adjusted meaning: ", round(context_scores[end], digits=3))
println("Mean directed-life index: ", round(mean(directed_scores), digits=3))
println("Final directed-life index: ", round(directed_scores[end], digits=3))
println("Mean search-context index: ", round(mean(search_scores), digits=3))
println("Final search-context index: ", round(search_scores[end], digits=3))
