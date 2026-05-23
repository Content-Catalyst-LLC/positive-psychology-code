# Explanatory style and optimism systems dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, therapeutic, employment,
# school disciplinary, benefits eligibility, ranking, or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "negative_stability",
    "negative_globality",
    "negative_personalization",
    "positive_stability",
    "positive_globality",
    "positive_effort",
    "setback_intensity",
    "controllability",
    "agency",
    "support",
    "persistence",
    "hope",
    "wellbeing",
    "distress"
]

state = [0.47, 0.45, 0.46, 0.58, 0.56, 0.57, 0.51, 0.57, 0.58, 0.59, 0.58, 0.59, 0.58, 0.49]

A = [
    0.82 0.06 0.06 -0.03 -0.03 -0.03 0.05 -0.04 -0.05 -0.04 -0.05 -0.05 -0.05 0.06;
    0.06 0.82 0.06 -0.03 -0.03 -0.03 0.05 -0.04 -0.05 -0.04 -0.05 -0.05 -0.05 0.06;
    0.06 0.06 0.82 -0.03 -0.03 -0.03 0.06 -0.04 -0.06 -0.04 -0.06 -0.06 -0.06 0.07;
    -0.03 -0.03 -0.03 0.84 0.06 0.06 -0.03 0.04 0.05 0.04 0.05 0.06 0.05 -0.04;
    -0.03 -0.03 -0.03 0.06 0.84 0.06 -0.03 0.04 0.05 0.04 0.05 0.06 0.05 -0.04;
    -0.03 -0.03 -0.03 0.06 0.06 0.84 -0.03 0.05 0.06 0.04 0.06 0.06 0.05 -0.04;
    0.05 0.05 0.06 -0.03 -0.03 -0.03 0.82 -0.05 -0.06 -0.05 -0.06 -0.06 -0.06 0.07;
    -0.04 -0.04 -0.04 0.04 0.04 0.05 -0.05 0.84 0.06 0.05 0.06 0.06 0.05 -0.05;
    -0.05 -0.05 -0.06 0.05 0.05 0.06 -0.06 0.06 0.84 0.06 0.07 0.07 0.06 -0.06;
    -0.04 -0.04 -0.04 0.04 0.04 0.04 -0.05 0.05 0.06 0.84 0.06 0.06 0.06 -0.05;
    -0.05 -0.05 -0.06 0.05 0.05 0.06 -0.06 0.06 0.07 0.06 0.84 0.07 0.06 -0.06;
    -0.05 -0.05 -0.06 0.06 0.06 0.06 -0.06 0.06 0.07 0.06 0.07 0.84 0.07 -0.06;
    -0.05 -0.05 -0.06 0.05 0.05 0.05 -0.06 0.05 0.06 0.06 0.06 0.07 0.84 -0.07;
    0.06 0.06 0.07 -0.04 -0.04 -0.04 0.07 -0.05 -0.06 -0.05 -0.06 -0.06 -0.07 0.82
]

function step_system(state, A; reappraisal_boost=zeros(length(state)), setback_shock=zeros(length(state)))
    next_state = A * state + reappraisal_boost + setback_shock
    return clamp.(next_state, 0.0, 1.0)
end

function explanatory_burden(state)
    return mean(state[1:3])
end

function positive_event_integration(state)
    return mean(state[4:6])
end

function context_adjusted_agency(state)
    return state[9] + state[10] + state[8] - state[7] - explanatory_burden(state)
end

function resilient_persistence_index(state)
    return state[11] + state[12] + state[9] + state[10] + positive_event_integration(state) -
           state[7] - explanatory_burden(state) - state[14]
end

history = Matrix{Float64}(undef, 32, length(state))
history[1, :] = state

for t in 2:32
    reappraisal_boost = zeros(length(state))
    setback_shock = zeros(length(state))

    if t <= 10
        reappraisal_boost[4] = 0.014  # positive stability
        reappraisal_boost[5] = 0.014  # positive globality
        reappraisal_boost[6] = 0.014  # positive effort
        reappraisal_boost[9] = 0.015  # agency
        reappraisal_boost[10] = 0.015 # support
    end

    if t == 12
        setback_shock[1] = 0.07  # stability
        setback_shock[2] = 0.07  # globality
        setback_shock[3] = 0.08  # personalization
        setback_shock[7] = 0.10  # setback intensity
        setback_shock[14] = 0.07 # distress
    end

    if t >= 18 && t <= 26
        reappraisal_boost[1] = -0.012 # lower negative stability
        reappraisal_boost[2] = -0.012 # lower negative globality
        reappraisal_boost[3] = -0.012 # lower negative personalization
        reappraisal_boost[8] = 0.014  # controllability
        reappraisal_boost[11] = 0.015 # persistence
        reappraisal_boost[12] = 0.015 # hope
        reappraisal_boost[13] = 0.012 # wellbeing
    end

    history[t, :] = step_system(history[t - 1, :], A; reappraisal_boost=reappraisal_boost, setback_shock=setback_shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

burden_scores = [explanatory_burden(history[t, :]) for t in 1:size(history, 1)]
positive_scores = [positive_event_integration(history[t, :]) for t in 1:size(history, 1)]
agency_scores = [context_adjusted_agency(history[t, :]) for t in 1:size(history, 1)]
persistence_scores = [resilient_persistence_index(history[t, :]) for t in 1:size(history, 1)]

println("\nMean explanatory burden: ", round(mean(burden_scores), digits=3))
println("Final explanatory burden: ", round(burden_scores[end], digits=3))
println("Mean positive-event integration: ", round(mean(positive_scores), digits=3))
println("Final positive-event integration: ", round(positive_scores[end], digits=3))
println("Mean context-adjusted agency: ", round(mean(agency_scores), digits=3))
println("Final context-adjusted agency: ", round(agency_scores[end], digits=3))
println("Mean resilient persistence index: ", round(mean(persistence_scores), digits=3))
println("Final resilient persistence index: ", round(persistence_scores[end], digits=3))
