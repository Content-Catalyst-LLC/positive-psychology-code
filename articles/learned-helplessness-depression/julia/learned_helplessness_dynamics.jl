# Learned helplessness and agency-recovery systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, benefits eligibility, ranking, crisis support, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "perceived_control",
    "uncontrollable_events",
    "stability",
    "globality",
    "internality",
    "motivation",
    "depressive_symptoms",
    "agency",
    "support",
    "mastery",
    "recovery",
    "feedback_quality",
    "institutional_fairness"
]

state = [0.58, 0.49, 0.45, 0.44, 0.46, 0.57, 0.48, 0.58, 0.60, 0.57, 0.58, 0.60, 0.59]

A = [
    0.84 -0.06 -0.04 -0.04 -0.04 0.06 -0.05 0.07 0.06 0.06 0.06 0.05 0.06;
    -0.06 0.82 0.06 0.06 0.06 -0.06 0.07 -0.06 -0.05 -0.05 -0.05 -0.04 -0.05;
    -0.04 0.06 0.82 0.06 0.06 -0.05 0.06 -0.05 -0.04 -0.04 -0.04 -0.04 -0.04;
    -0.04 0.06 0.06 0.82 0.06 -0.05 0.06 -0.05 -0.04 -0.04 -0.04 -0.04 -0.04;
    -0.04 0.06 0.06 0.06 0.82 -0.05 0.07 -0.05 -0.04 -0.04 -0.04 -0.04 -0.04;
    0.06 -0.06 -0.05 -0.05 -0.05 0.84 -0.07 0.07 0.06 0.06 0.06 0.06 0.06;
    -0.05 0.07 0.06 0.06 0.07 -0.07 0.82 -0.06 -0.05 -0.05 -0.05 -0.04 -0.05;
    0.07 -0.06 -0.05 -0.05 -0.05 0.07 -0.06 0.84 0.06 0.06 0.06 0.05 0.06;
    0.06 -0.05 -0.04 -0.04 -0.04 0.06 -0.05 0.06 0.84 0.05 0.06 0.05 0.05;
    0.06 -0.05 -0.04 -0.04 -0.04 0.06 -0.05 0.06 0.05 0.84 0.06 0.06 0.05;
    0.06 -0.05 -0.04 -0.04 -0.04 0.06 -0.05 0.06 0.06 0.06 0.84 0.05 0.05;
    0.05 -0.04 -0.04 -0.04 -0.04 0.06 -0.04 0.05 0.05 0.06 0.05 0.84 0.05;
    0.06 -0.05 -0.04 -0.04 -0.04 0.06 -0.05 0.06 0.05 0.05 0.05 0.05 0.84
]

function step_system(state, A; recovery_boost=zeros(length(state)), uncontrollable_shock=zeros(length(state)))
    next_state = A * state + recovery_boost + uncontrollable_shock
    return clamp.(next_state, 0.0, 1.0)
end

function helplessness_index(state)
    return mean(state[3:5])
end

function control_gap(state)
    return state[1] - state[2]
end

function agency_recovery_index(state)
    return state[8] + state[9] + state[10] + state[11] + state[12] + state[13] - state[2] - helplessness_index(state)
end

function motivation_protection_index(state)
    return state[6] + state[1] + state[8] + state[9] + state[10] + state[12] + state[13] -
           state[2] - helplessness_index(state) - state[7]
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    recovery_boost = zeros(length(state))
    uncontrollable_shock = zeros(length(state))

    if t <= 10
        recovery_boost[1] = 0.014  # perceived control
        recovery_boost[8] = 0.014  # agency
        recovery_boost[9] = 0.014  # support
        recovery_boost[10] = 0.014 # mastery
        recovery_boost[12] = 0.012 # feedback
        recovery_boost[13] = 0.012 # fairness
    end

    if t == 12
        uncontrollable_shock[2] = 0.10 # uncontrollable events
        uncontrollable_shock[3] = 0.07 # stability
        uncontrollable_shock[4] = 0.07 # globality
        uncontrollable_shock[5] = 0.08 # internality
        uncontrollable_shock[7] = 0.07 # depressive symptoms
        uncontrollable_shock[6] = -0.04 # motivation
    end

    if t >= 18 && t <= 26
        recovery_boost[1] = 0.016  # perceived control
        recovery_boost[3] = -0.010 # stability down
        recovery_boost[4] = -0.010 # globality down
        recovery_boost[5] = -0.010 # internality down
        recovery_boost[6] = 0.016  # motivation
        recovery_boost[8] = 0.016  # agency
        recovery_boost[11] = 0.014 # recovery opportunity
    end

    history[t, :] = step_system(history[t - 1, :], A; recovery_boost=recovery_boost, uncontrollable_shock=uncontrollable_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

helplessness_scores = [helplessness_index(history[t, :]) for t in 1:size(history, 1)]
control_gap_scores = [control_gap(history[t, :]) for t in 1:size(history, 1)]
recovery_scores = [agency_recovery_index(history[t, :]) for t in 1:size(history, 1)]
protection_scores = [motivation_protection_index(history[t, :]) for t in 1:size(history, 1)]

println("\nMean helplessness index: ", round(mean(helplessness_scores), digits=3))
println("Final helplessness index: ", round(helplessness_scores[end], digits=3))
println("Mean control gap: ", round(mean(control_gap_scores), digits=3))
println("Final control gap: ", round(control_gap_scores[end], digits=3))
println("Mean agency-recovery index: ", round(mean(recovery_scores), digits=3))
println("Final agency-recovery index: ", round(recovery_scores[end], digits=3))
println("Mean motivation-protection index: ", round(mean(protection_scores), digits=3))
println("Final motivation-protection index: ", round(protection_scores[end], digits=3))
