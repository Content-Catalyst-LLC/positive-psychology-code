# Self-Determination Theory motivational dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, ranking, public-benefits, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "autonomy_support",
    "competence_support",
    "relatedness_support",
    "need_frustration",
    "controlling_pressure",
    "autonomous_motivation",
    "controlled_motivation",
    "internalization",
    "wellbeing",
    "vitality",
    "stress_load",
    "climate_quality"
]

state = [0.66, 0.67, 0.66, 0.34, 0.38, 0.64, 0.42, 0.61, 0.65, 0.64, 0.40, 0.66]

A = [
    0.84 0.04 0.05 -0.05 -0.06 0.06 -0.04 0.05 0.05 0.05 -0.05 0.07;
    0.04 0.84 0.04 -0.04 -0.05 0.05 -0.04 0.05 0.05 0.05 -0.05 0.07;
    0.05 0.04 0.84 -0.06 -0.05 0.06 -0.04 0.06 0.05 0.05 -0.05 0.07;
    -0.05 -0.04 -0.06 0.82 0.07 -0.05 0.06 -0.04 -0.05 -0.05 0.06 -0.06;
    -0.06 -0.05 -0.05 0.07 0.82 -0.06 0.07 -0.05 -0.05 -0.05 0.07 -0.06;
    0.06 0.05 0.06 -0.05 -0.06 0.84 -0.06 0.07 0.06 0.06 -0.05 0.05;
    -0.04 -0.04 -0.04 0.06 0.07 -0.06 0.82 -0.05 -0.04 -0.04 0.05 -0.05;
    0.05 0.05 0.06 -0.04 -0.05 0.07 -0.05 0.84 0.06 0.05 -0.04 0.05;
    0.05 0.05 0.05 -0.05 -0.05 0.06 -0.04 0.06 0.84 0.07 -0.06 0.05;
    0.05 0.05 0.05 -0.05 -0.05 0.06 -0.04 0.05 0.07 0.84 -0.06 0.05;
    -0.05 -0.05 -0.05 0.06 0.07 -0.05 0.05 -0.04 -0.06 -0.06 0.82 -0.05;
    0.07 0.07 0.07 -0.06 -0.06 0.05 -0.05 0.05 0.05 0.05 -0.05 0.84
]

function step_system(state, A; support_boost=zeros(length(state)), control_shock=zeros(length(state)))
    next_state = A * state + support_boost + control_shock
    return clamp.(next_state, 0.0, 1.0)
end

function need_support_index(state)
    return mean(state[[1, 2, 3]])
end

function need_balance_index(state)
    return need_support_index(state) - state[4] - state[5]
end

function motivational_quality_index(state)
    return state[6] + state[8] - state[7]
end

function net_sdt_wellbeing(state)
    return state[9] + state[10] + state[6] + state[8] + need_support_index(state) - state[7] - state[11] - state[4] - state[5]
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    support_boost = zeros(length(state))
    control_shock = zeros(length(state))

    if t <= 10
        support_boost[1] = 0.020  # autonomy support
        support_boost[2] = 0.020  # competence support
        support_boost[3] = 0.020  # relatedness support
        support_boost[12] = 0.015 # climate quality
    end

    if t == 12
        control_shock[5] = 0.08   # controlling pressure shock
        control_shock[4] = 0.06   # need frustration shock
        control_shock[11] = 0.06  # stress load shock
    end

    if t == 18
        support_boost[1] = 0.05   # autonomy-supportive redesign
        support_boost[2] = 0.04   # competence scaffolding
        support_boost[3] = 0.05   # relatedness climate
        support_boost[8] = 0.04   # internalization
        support_boost[12] = 0.05  # climate quality
    end

    history[t, :] = step_system(history[t - 1, :], A; support_boost=support_boost, control_shock=control_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

need_balance_scores = [need_balance_index(history[t, :]) for t in 1:size(history, 1)]
motivational_quality_scores = [motivational_quality_index(history[t, :]) for t in 1:size(history, 1)]
net_scores = [net_sdt_wellbeing(history[t, :]) for t in 1:size(history, 1)]

println("\nMean need balance: ", round(mean(need_balance_scores), digits=3))
println("Final need balance: ", round(need_balance_scores[end], digits=3))
println("Mean motivational quality: ", round(mean(motivational_quality_scores), digits=3))
println("Final motivational quality: ", round(motivational_quality_scores[end], digits=3))
println("Mean net SDT wellbeing: ", round(mean(net_scores), digits=3))
println("Final net SDT wellbeing: ", round(net_scores[end], digits=3))
