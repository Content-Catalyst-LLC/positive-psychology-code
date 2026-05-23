# School climate and student flourishing dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, disciplinary, ranking,
# public-benefits, employment, or individual student assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "academic_development",
    "engagement",
    "belonging",
    "resilience",
    "life_satisfaction",
    "school_climate",
    "teacher_support",
    "purpose_learning",
    "stress_load",
    "exclusion_exposure",
    "access_support",
    "student_voice"
]

state = [0.70, 0.66, 0.67, 0.65, 0.66, 0.68, 0.69, 0.65, 0.40, 0.32, 0.67, 0.65]

A = [
    0.82 0.06 0.03 0.04 0.03 0.04 0.04 0.04 -0.04 -0.05 0.04 0.03;
    0.05 0.82 0.06 0.04 0.04 0.05 0.05 0.05 -0.05 -0.05 0.04 0.04;
    0.03 0.06 0.84 0.04 0.04 0.06 0.07 0.04 -0.05 -0.07 0.06 0.06;
    0.04 0.04 0.04 0.83 0.05 0.04 0.04 0.05 -0.05 -0.04 0.04 0.04;
    0.03 0.04 0.04 0.05 0.82 0.05 0.05 0.04 -0.06 -0.05 0.04 0.04;
    0.04 0.05 0.06 0.04 0.05 0.84 0.07 0.04 -0.05 -0.06 0.07 0.06;
    0.04 0.05 0.07 0.04 0.05 0.07 0.84 0.04 -0.04 -0.05 0.05 0.05;
    0.04 0.05 0.04 0.05 0.04 0.04 0.04 0.83 -0.04 -0.04 0.04 0.05;
    -0.04 -0.05 -0.05 -0.05 -0.06 -0.05 -0.04 -0.04 0.82 0.06 -0.05 -0.04;
    -0.05 -0.05 -0.07 -0.04 -0.05 -0.06 -0.05 -0.04 0.06 0.82 -0.06 -0.05;
    0.04 0.04 0.06 0.04 0.04 0.07 0.05 0.04 -0.05 -0.06 0.84 0.06;
    0.03 0.04 0.06 0.04 0.04 0.06 0.05 0.05 -0.04 -0.05 0.06 0.83
]

function step_system(state, A; shock=zeros(length(state)))
    next_state = A * state + shock
    return clamp.(next_state, 0.0, 1.0)
end

function school_flourishing_score(state)
    positive = mean(state[[1,2,3,4,5,6,7,8,11,12]])
    burden = mean(state[[9,10]])
    return positive - 0.55 * burden
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    shock = zeros(length(state))

    if t == 8
        shock[9] = 0.08   # stress shock
        shock[10] = 0.06  # exclusion shock
    end

    if t == 16
        shock[6] = 0.08   # school climate investment
        shock[7] = 0.07   # teacher support investment
        shock[11] = 0.07  # access support investment
        shock[12] = 0.06  # student voice investment
    end

    history[t, :] = step_system(history[t - 1, :], A; shock=shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

scores = [school_flourishing_score(history[t, :]) for t in 1:size(history, 1)]
println("\nMean school flourishing score: ", round(mean(scores), digits=3))
println("Final school flourishing score: ", round(scores[end], digits=3))
