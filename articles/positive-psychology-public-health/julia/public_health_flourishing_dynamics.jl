# Systems simulation scaffold for positive psychology and public health.
#
# Synthetic demonstration only. Not for clinical, employment, public-benefits,
# or individual assessment use.

using LinearAlgebra
using Statistics
using Random

Random.seed!(42)

domains = [
    "life_satisfaction",
    "health",
    "social_trust",
    "income_security",
    "institutions",
    "housing",
    "education",
    "care",
    "environment",
    "community_resilience",
    "stress_load"
]

state = [0.66, 0.67, 0.64, 0.62, 0.61, 0.60, 0.63, 0.61, 0.60, 0.62, 0.44]

# Supportive domains reinforce one another; stress load reduces health and well-being.
A = [
    0.80 0.05 0.04 0.04 0.04 0.03 0.03 0.04 0.03 0.05 -0.06;
    0.05 0.82 0.03 0.03 0.04 0.04 0.03 0.05 0.04 0.05 -0.07;
    0.04 0.03 0.84 0.03 0.07 0.03 0.03 0.03 0.02 0.06 -0.05;
    0.04 0.03 0.03 0.83 0.04 0.05 0.03 0.03 0.02 0.03 -0.06;
    0.04 0.04 0.07 0.04 0.84 0.04 0.04 0.05 0.03 0.06 -0.06;
    0.03 0.04 0.03 0.05 0.04 0.84 0.03 0.04 0.03 0.04 -0.07;
    0.03 0.03 0.03 0.03 0.04 0.03 0.85 0.03 0.02 0.03 -0.04;
    0.04 0.05 0.03 0.03 0.05 0.04 0.03 0.84 0.03 0.05 -0.06;
    0.03 0.04 0.02 0.02 0.03 0.03 0.02 0.03 0.86 0.04 -0.04;
    0.05 0.05 0.06 0.03 0.06 0.04 0.03 0.05 0.04 0.82 -0.07;
    -0.05 -0.06 -0.04 -0.05 -0.05 -0.06 -0.03 -0.05 -0.04 -0.06 0.80
]

function step_system(state, A; shock=zeros(length(state)))
    next_state = A * state + shock
    return clamp.(next_state, 0.0, 1.0)
end

history = Matrix{Float64}(undef, 25, length(state))
history[1, :] = state

for t in 2:25
    shock = zeros(length(state))
    if t == 8
        shock[11] = 0.10    # stress-load shock
        shock[6] = -0.05    # housing-stability stress
    end
    if t == 14
        shock[5] = 0.08     # institutional investment
        shock[8] = 0.07     # care-access investment
        shock[10] = 0.06    # community-resilience investment
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
