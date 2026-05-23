# Flow and optimal experience systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, productivity-surveillance, benefits eligibility,
# ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "challenge",
    "skill",
    "attention",
    "feedback",
    "goal_clarity",
    "task_meaning",
    "autonomy",
    "distraction",
    "interruptions",
    "flow",
    "performance",
    "learning_gain",
    "fatigue",
    "recovery",
    "wellbeing"
]

state = [0.62, 0.60, 0.64, 0.62, 0.65, 0.66, 0.64, 0.39, 0.20, 0.63, 0.62, 0.22, 0.38, 0.64, 0.63]

A = [
    0.84 0.06 0.04 0.04 0.04 0.04 0.03 -0.03 -0.03 0.05 0.05 0.04 0.03 0.02 0.03;
    0.06 0.84 0.05 0.05 0.04 0.04 0.04 -0.03 -0.03 0.06 0.06 0.06 -0.03 0.03 0.04;
    0.04 0.05 0.84 0.06 0.06 0.05 0.05 -0.07 -0.06 0.07 0.05 0.04 -0.05 0.05 0.05;
    0.04 0.05 0.06 0.84 0.06 0.05 0.04 -0.04 -0.04 0.06 0.06 0.05 -0.03 0.04 0.04;
    0.04 0.04 0.06 0.06 0.84 0.05 0.04 -0.04 -0.04 0.06 0.05 0.04 -0.03 0.04 0.04;
    0.04 0.04 0.05 0.05 0.05 0.84 0.06 -0.03 -0.03 0.06 0.05 0.04 -0.02 0.04 0.06;
    0.03 0.04 0.05 0.04 0.04 0.06 0.84 -0.04 -0.04 0.06 0.04 0.04 -0.03 0.05 0.05;
    -0.03 -0.03 -0.07 -0.04 -0.04 -0.03 -0.04 0.82 0.07 -0.07 -0.04 -0.03 0.06 -0.05 -0.05;
    -0.03 -0.03 -0.06 -0.04 -0.04 -0.03 -0.04 0.07 0.82 -0.06 -0.04 -0.03 0.05 -0.04 -0.04;
    0.05 0.06 0.07 0.06 0.06 0.06 0.06 -0.07 -0.06 0.84 0.07 0.05 -0.05 0.05 0.06;
    0.05 0.06 0.05 0.06 0.05 0.05 0.04 -0.04 -0.04 0.07 0.84 0.06 -0.04 0.04 0.05;
    0.04 0.06 0.04 0.05 0.04 0.04 0.04 -0.03 -0.03 0.05 0.06 0.84 -0.03 0.04 0.04;
    0.03 -0.03 -0.05 -0.03 -0.03 -0.02 -0.03 0.06 0.05 -0.05 -0.04 -0.03 0.82 -0.07 -0.05;
    0.02 0.03 0.05 0.04 0.04 0.04 0.05 -0.05 -0.04 0.05 0.04 0.04 -0.07 0.84 0.06;
    0.03 0.04 0.05 0.04 0.04 0.06 0.05 -0.05 -0.04 0.06 0.05 0.04 -0.05 0.06 0.84
]

function step_system(state, A; design_boost=zeros(length(state)), disruption=zeros(length(state)))
    next_state = A * state + design_boost + disruption
    return clamp.(next_state, 0.0, 1.0)
end

function balance_index(state)
    return 1.0 - abs(state[1] - state[2])
end

function attentional_ecology(state)
    return state[3] + state[4] + state[5] - state[8] - state[9]
end

function deep_engagement_context(state)
    return balance_index(state) + state[3] + state[4] + state[5] + state[6] + state[7] - state[8] - state[9]
end

function sustainable_flow_index(state)
    return state[10] + state[6] + state[7] + state[14] - state[13] - state[8]
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    design_boost = zeros(length(state))
    disruption = zeros(length(state))

    if t <= 10
        design_boost[4] = 0.015  # feedback
        design_boost[5] = 0.015  # goal clarity
        design_boost[7] = 0.012  # autonomy
        design_boost[14] = 0.010 # recovery
    end

    if t == 12
        disruption[8] = 0.10  # distraction
        disruption[9] = 0.08  # interruptions
        disruption[13] = 0.06 # fatigue
        disruption[3] = -0.04 # attention
    end

    if t >= 18 && t <= 25
        design_boost[1] = 0.015  # challenge
        design_boost[2] = 0.018  # skill
        design_boost[3] = 0.020  # attention
        design_boost[6] = 0.015  # meaning
        design_boost[10] = 0.015 # flow
        design_boost[12] = 0.010 # learning
    end

    history[t, :] = step_system(history[t - 1, :], A; design_boost=design_boost, disruption=disruption)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

balance_scores = [balance_index(history[t, :]) for t in 1:size(history, 1)]
attention_scores = [attentional_ecology(history[t, :]) for t in 1:size(history, 1)]
engagement_scores = [deep_engagement_context(history[t, :]) for t in 1:size(history, 1)]
sustainable_scores = [sustainable_flow_index(history[t, :]) for t in 1:size(history, 1)]

println("\nMean challenge-skill balance: ", round(mean(balance_scores), digits=3))
println("Final challenge-skill balance: ", round(balance_scores[end], digits=3))
println("Mean attentional ecology: ", round(mean(attention_scores), digits=3))
println("Final attentional ecology: ", round(attention_scores[end], digits=3))
println("Mean deep engagement context: ", round(mean(engagement_scores), digits=3))
println("Final deep engagement context: ", round(engagement_scores[end], digits=3))
println("Mean sustainable flow index: ", round(mean(sustainable_scores), digits=3))
println("Final sustainable flow index: ", round(sustainable_scores[end], digits=3))
