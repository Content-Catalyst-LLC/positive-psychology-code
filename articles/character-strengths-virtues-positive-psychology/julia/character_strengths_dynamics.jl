# Character strengths and virtues systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, benefits eligibility, moral ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "wisdom",
    "courage",
    "humanity",
    "justice",
    "temperance",
    "transcendence",
    "signature_use",
    "authenticity",
    "contextual_support",
    "institutional_suppression",
    "overuse_risk",
    "flourishing",
    "meaning",
    "relationships",
    "engagement"
]

state = [0.66, 0.63, 0.68, 0.66, 0.64, 0.68, 0.66, 0.67, 0.64, 0.36, 0.33, 0.65, 0.66, 0.65, 0.67]

A = [
    0.84 0.04 0.03 0.03 0.04 0.04 0.05 0.04 0.04 -0.03 -0.03 0.05 0.05 0.04 0.06;
    0.04 0.84 0.03 0.04 0.04 0.04 0.05 0.05 0.04 -0.04 -0.04 0.05 0.04 0.04 0.05;
    0.03 0.03 0.84 0.05 0.04 0.04 0.05 0.05 0.05 -0.04 -0.03 0.06 0.05 0.07 0.05;
    0.03 0.04 0.05 0.84 0.05 0.04 0.04 0.04 0.06 -0.05 -0.04 0.06 0.04 0.06 0.04;
    0.04 0.04 0.04 0.05 0.84 0.04 0.04 0.05 0.04 -0.04 -0.06 0.05 0.04 0.04 0.05;
    0.04 0.04 0.04 0.04 0.04 0.84 0.05 0.06 0.04 -0.03 -0.03 0.06 0.07 0.05 0.04;
    0.05 0.05 0.05 0.04 0.04 0.05 0.84 0.07 0.06 -0.05 -0.05 0.07 0.06 0.06 0.06;
    0.04 0.05 0.05 0.04 0.05 0.06 0.07 0.84 0.05 -0.06 -0.05 0.07 0.06 0.06 0.06;
    0.04 0.04 0.05 0.06 0.04 0.04 0.06 0.05 0.84 -0.07 -0.04 0.06 0.05 0.06 0.05;
    -0.03 -0.04 -0.04 -0.05 -0.04 -0.03 -0.05 -0.06 -0.07 0.82 0.06 -0.06 -0.05 -0.05 -0.05;
    -0.03 -0.04 -0.03 -0.04 -0.06 -0.03 -0.05 -0.05 -0.04 0.06 0.82 -0.05 -0.04 -0.04 -0.05;
    0.05 0.05 0.06 0.06 0.05 0.06 0.07 0.07 0.06 -0.06 -0.05 0.84 0.07 0.07 0.07;
    0.05 0.04 0.05 0.04 0.04 0.07 0.06 0.06 0.05 -0.05 -0.04 0.07 0.84 0.06 0.06;
    0.04 0.04 0.07 0.06 0.04 0.05 0.06 0.06 0.06 -0.05 -0.04 0.07 0.06 0.84 0.05;
    0.06 0.05 0.05 0.04 0.05 0.04 0.06 0.06 0.05 -0.05 -0.05 0.07 0.06 0.05 0.84
]

function step_system(state, A; formation_boost=zeros(length(state)), institutional_shock=zeros(length(state)))
    next_state = A * state + formation_boost + institutional_shock
    return clamp.(next_state, 0.0, 1.0)
end

function virtue_profile_mean(state)
    return mean(state[1:6])
end

function strength_expression_index(state)
    return state[7] + state[8] + state[9] - state[10] - state[11]
end

function civic_character_index(state)
    return mean([state[4], state[5], state[8], state[9]])
end

function relational_character_index(state)
    return mean([state[3], state[6], state[8], state[14]])
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    formation_boost = zeros(length(state))
    institutional_shock = zeros(length(state))

    if t <= 10
        formation_boost[1] = 0.014  # wisdom
        formation_boost[3] = 0.014  # humanity
        formation_boost[6] = 0.014  # transcendence
        formation_boost[9] = 0.015  # contextual support
    end

    if t == 12
        institutional_shock[10] = 0.09  # suppression
        institutional_shock[11] = 0.07  # overuse risk
        institutional_shock[8] = -0.04  # authenticity
        institutional_shock[12] = -0.04 # flourishing
    end

    if t >= 18 && t <= 26
        formation_boost[2] = 0.015  # courage
        formation_boost[4] = 0.015  # justice
        formation_boost[5] = 0.014  # temperance
        formation_boost[7] = 0.015  # signature use
        formation_boost[8] = 0.015  # authenticity
        formation_boost[12] = 0.015 # flourishing
    end

    history[t, :] = step_system(history[t - 1, :], A; formation_boost=formation_boost, institutional_shock=institutional_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

virtue_scores = [virtue_profile_mean(history[t, :]) for t in 1:size(history, 1)]
expression_scores = [strength_expression_index(history[t, :]) for t in 1:size(history, 1)]
civic_scores = [civic_character_index(history[t, :]) for t in 1:size(history, 1)]
relational_scores = [relational_character_index(history[t, :]) for t in 1:size(history, 1)]

println("\nMean virtue profile: ", round(mean(virtue_scores), digits=3))
println("Final virtue profile: ", round(virtue_scores[end], digits=3))
println("Mean strength-expression index: ", round(mean(expression_scores), digits=3))
println("Final strength-expression index: ", round(expression_scores[end], digits=3))
println("Mean civic character index: ", round(mean(civic_scores), digits=3))
println("Final civic character index: ", round(civic_scores[end], digits=3))
println("Mean relational character index: ", round(mean(relational_scores), digits=3))
println("Final relational character index: ", round(relational_scores[end], digits=3))
