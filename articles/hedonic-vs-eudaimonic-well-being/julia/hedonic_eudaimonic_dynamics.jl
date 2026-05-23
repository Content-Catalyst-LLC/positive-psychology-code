# Systems simulation scaffold for hedonic and eudaimonic well-being.
#
# Synthetic demonstration only. Not for clinical, employment, public-benefits,
# or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "life_satisfaction",
    "positive_affect",
    "negative_affect",
    "autonomy",
    "personal_growth",
    "purpose_life",
    "positive_relations",
    "contextual_support",
    "stress_load"
]

state = [0.68, 0.66, 0.34, 0.65, 0.66, 0.67, 0.68, 0.64, 0.38]

# Hedonic and eudaimonic domains reinforce each other, while stress load reduces both.
A = [
    0.82 0.06 -0.06 0.03 0.03 0.04 0.05 0.05 -0.06;
    0.06 0.82 -0.07 0.03 0.03 0.04 0.05 0.04 -0.07;
    -0.04 -0.04 0.80 -0.03 -0.03 -0.03 -0.04 -0.04 0.07;
    0.03 0.03 -0.03 0.84 0.06 0.05 0.04 0.05 -0.05;
    0.03 0.03 -0.03 0.06 0.84 0.06 0.04 0.04 -0.05;
    0.04 0.04 -0.03 0.05 0.06 0.84 0.05 0.04 -0.05;
    0.05 0.05 -0.04 0.04 0.04 0.05 0.84 0.05 -0.05;
    0.05 0.04 -0.04 0.05 0.04 0.04 0.05 0.84 -0.06;
    -0.05 -0.06 0.06 -0.04 -0.04 -0.04 -0.04 -0.05 0.82
]

function step_system(state, A; shock=zeros(length(state)))
    next_state = A * state + shock
    return clamp.(next_state, 0.0, 1.0)
end

function hedonic_score(state)
    return state[1] + state[2] - state[3]
end

function eudaimonic_score(state)
    return mean(state[4:7])
end

function integrated_score(state)
    return 0.40 * hedonic_score(state) + 0.45 * eudaimonic_score(state) + 0.20 * state[8] - 0.20 * state[9]
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    shock = zeros(length(state))

    if t == 8
        shock[3] = 0.08  # negative affect shock
        shock[9] = 0.08  # stress-load shock
    end

    if t == 16
        shock[6] = 0.07  # purpose investment
        shock[7] = 0.06  # relational investment
        shock[8] = 0.07  # contextual support investment
    end

    history[t, :] = step_system(history[t - 1, :], A; shock=shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

hed_scores = [hedonic_score(history[t, :]) for t in 1:size(history, 1)]
eud_scores = [eudaimonic_score(history[t, :]) for t in 1:size(history, 1)]
int_scores = [integrated_score(history[t, :]) for t in 1:size(history, 1)]

println("\nMean hedonic score: ", round(mean(hed_scores), digits=3))
println("Mean eudaimonic score: ", round(mean(eud_scores), digits=3))
println("Mean integrated flourishing score: ", round(mean(int_scores), digits=3))
println("Final integrated flourishing score: ", round(int_scores[end], digits=3))
