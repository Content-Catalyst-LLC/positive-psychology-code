# Systems simulation scaffold for positive psychology and sustainability.
#
# Synthetic demonstration only. Not for clinical, employment, public-benefits,
# or individual assessment use.

using Statistics
using Random

Random.seed!(42)

domains = [
    "psychological_functioning",
    "relational_support",
    "institutional_capacity",
    "ecological_stability",
    "health_capacity",
    "adaptive_capacity",
    "environmental_exposure",
    "insecurity_load",
    "inequality_burden"
]

state = [0.66, 0.65, 0.62, 0.60, 0.67, 0.63, 0.42, 0.44, 0.40]

# Supportive domains reinforce one another; exposure, insecurity, and inequality reduce flourishing.
A = [
    0.82 0.06 0.04 0.03 0.05 0.05 -0.05 -0.06 -0.05;
    0.05 0.84 0.05 0.03 0.04 0.05 -0.04 -0.05 -0.05;
    0.04 0.05 0.85 0.05 0.04 0.06 -0.05 -0.05 -0.06;
    0.03 0.03 0.05 0.86 0.04 0.05 -0.08 -0.03 -0.03;
    0.05 0.04 0.04 0.04 0.84 0.05 -0.06 -0.06 -0.05;
    0.05 0.05 0.06 0.05 0.05 0.83 -0.05 -0.05 -0.05;
    -0.04 -0.03 -0.04 -0.06 -0.05 -0.04 0.80 0.04 0.03;
    -0.05 -0.04 -0.04 -0.03 -0.05 -0.04 0.04 0.80 0.05;
    -0.04 -0.04 -0.05 -0.03 -0.04 -0.04 0.03 0.05 0.80
]

function step_system(state, A; shock=zeros(length(state)))
    next_state = A * state + shock
    return clamp.(next_state, 0.0, 1.0)
end

function sustainable_flourishing_score(state)
    positive = mean(state[1:6])
    burden = mean(state[7:9])
    return positive - 0.6 * burden
end

history = Matrix{Float64}(undef, 30, length(state))
history[1, :] = state

for t in 2:30
    shock = zeros(length(state))

    if t == 8
        shock[7] = 0.09   # environmental exposure shock
        shock[8] = 0.06   # insecurity shock
    end

    if t == 16
        shock[3] = 0.08   # institutional investment
        shock[4] = 0.07   # ecological repair
        shock[6] = 0.06   # adaptive capacity investment
    end

    history[t, :] = step_system(history[t - 1, :], A; shock=shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

println("\nFinal simulated state:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(history[end, i], digits=3))
end

scores = [sustainable_flourishing_score(history[t, :]) for t in 1:size(history, 1)]
println("\nMean sustainable flourishing score: ", round(mean(scores), digits=3))
println("Final sustainable flourishing score: ", round(scores[end], digits=3))
