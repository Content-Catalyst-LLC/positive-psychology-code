# Post-traumatic growth process dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, crisis-triage,
# employment, school disciplinary, benefits eligibility, legal, insurance,
# ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "assumptive_disruption",
    "intrusive_rumination",
    "deliberate_rumination",
    "meaning_making",
    "social_support",
    "restored_agency",
    "narrative_integration",
    "context_support",
    "ongoing_stress",
    "ptg_score",
    "distress_score",
    "wellbeing_score",
    "perceived_growth",
    "corroborated_growth"
]

state = [0.74, 0.68, 0.52, 0.55, 0.62, 0.56, 0.53, 0.60, 0.58, 0.57, 0.68, 0.58, 0.59, 0.51]

A = [
    0.86 0.06 -0.02 -0.02 -0.03 -0.03 -0.02 -0.03 0.06 -0.02 0.05 -0.03 -0.02 -0.02;
    0.06 0.84 -0.05 -0.04 -0.05 -0.04 -0.05 -0.04 0.06 -0.04 0.06 -0.05 -0.04 -0.04;
    -0.02 -0.05 0.84 0.07 0.05 0.05 0.07 0.05 -0.04 0.06 -0.04 0.04 0.05 0.05;
    -0.02 -0.04 0.07 0.84 0.06 0.07 0.08 0.06 -0.04 0.07 -0.04 0.05 0.06 0.06;
    -0.03 -0.05 0.05 0.06 0.84 0.06 0.06 0.07 -0.05 0.06 -0.05 0.06 0.05 0.05;
    -0.03 -0.04 0.05 0.07 0.06 0.84 0.07 0.06 -0.05 0.07 -0.05 0.06 0.06 0.06;
    -0.02 -0.05 0.07 0.08 0.06 0.07 0.84 0.06 -0.05 0.08 -0.05 0.06 0.06 0.07;
    -0.03 -0.04 0.05 0.06 0.07 0.06 0.06 0.84 -0.05 0.06 -0.05 0.06 0.05 0.05;
    0.06 0.06 -0.04 -0.04 -0.05 -0.05 -0.05 -0.05 0.84 -0.04 0.07 -0.06 -0.04 -0.04;
    -0.02 -0.04 0.06 0.07 0.06 0.07 0.08 0.06 -0.04 0.84 -0.04 0.07 0.08 0.06;
    0.05 0.06 -0.04 -0.04 -0.05 -0.05 -0.05 -0.05 0.07 -0.04 0.84 -0.07 -0.04 -0.04;
    -0.03 -0.05 0.04 0.05 0.06 0.06 0.06 0.06 -0.06 0.07 -0.07 0.84 0.06 0.05;
    -0.02 -0.04 0.05 0.06 0.05 0.06 0.06 0.05 -0.04 0.08 -0.04 0.06 0.84 0.06;
    -0.02 -0.04 0.05 0.06 0.05 0.06 0.07 0.05 -0.04 0.06 -0.04 0.05 0.06 0.84
]

function step_system(state, A; recovery_boost=zeros(length(state)), stress_shock=zeros(length(state)))
    next_state = A * state + recovery_boost + stress_shock
    return clamp.(next_state, 0.0, 1.0)
end

function integration_index(state)
    return mean(state[[4, 5, 6, 7, 8]])
end

function reflection_balance(state)
    return state[3] - state[2]
end

function growth_distress_balance(state)
    return state[10] + state[12] + integration_index(state) - state[11] - state[9]
end

function growth_alignment(state)
    return state[13] + state[14] - abs(state[13] - state[14])
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    recovery_boost = zeros(length(state))
    stress_shock = zeros(length(state))

    if t <= 8
        recovery_boost[5] = 0.015  # social support
        recovery_boost[8] = 0.015  # context support
    end

    if t == 10
        stress_shock[2] = 0.08   # intrusive rumination
        stress_shock[9] = 0.07   # ongoing stress
        stress_shock[11] = 0.06  # distress
    end

    if t >= 16 && t <= 24
        recovery_boost[3] = 0.020  # deliberate rumination
        recovery_boost[4] = 0.025  # meaning-making
        recovery_boost[6] = 0.020  # restored agency
        recovery_boost[7] = 0.025  # narrative integration
        recovery_boost[10] = 0.015 # PTG
        recovery_boost[14] = 0.015 # corroborated growth
    end

    history[t, :] = step_system(history[t - 1, :], A; recovery_boost=recovery_boost, stress_shock=stress_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

integration_scores = [integration_index(history[t, :]) for t in 1:size(history, 1)]
reflection_scores = [reflection_balance(history[t, :]) for t in 1:size(history, 1)]
balance_scores = [growth_distress_balance(history[t, :]) for t in 1:size(history, 1)]
alignment_scores = [growth_alignment(history[t, :]) for t in 1:size(history, 1)]

println("\nMean integration index: ", round(mean(integration_scores), digits=3))
println("Final integration index: ", round(integration_scores[end], digits=3))
println("Mean reflection balance: ", round(mean(reflection_scores), digits=3))
println("Final reflection balance: ", round(reflection_scores[end], digits=3))
println("Mean growth-distress balance: ", round(mean(balance_scores), digits=3))
println("Final growth-distress balance: ", round(balance_scores[end], digits=3))
println("Mean growth alignment: ", round(mean(alignment_scores), digits=3))
println("Final growth alignment: ", round(alignment_scores[end], digits=3))
