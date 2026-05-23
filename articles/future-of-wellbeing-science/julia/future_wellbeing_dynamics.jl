# Systems simulation scaffold for future well-being science.
#
# Synthetic demonstration only. Not for clinical, employment, or individual assessment use.

using LinearAlgebra
using Statistics
using Random

Random.seed!(42)

domains = [
    "psychological",
    "social_trust",
    "institutional",
    "environmental",
    "health",
    "resilience",
    "stress"
]

state = [0.60, 0.55, 0.58, 0.52, 0.62, 0.57, 0.45]

# Positive coupling among supportive domains; stress has negative coupling.
A = [
    0.80 0.06 0.04 0.02 0.05 0.06 -0.05;
    0.05 0.82 0.08 0.02 0.03 0.05 -0.06;
    0.04 0.08 0.84 0.05 0.03 0.04 -0.05;
    0.02 0.03 0.05 0.86 0.05 0.02 -0.04;
    0.05 0.03 0.03 0.05 0.83 0.06 -0.06;
    0.06 0.05 0.04 0.02 0.06 0.82 -0.08;
    -0.04 -0.05 -0.04 -0.03 -0.05 -0.06 0.78
]

function step_system(state, A; shock=zeros(length(state)))
    next_state = A * state + shock
    return clamp.(next_state, 0.0, 1.0)
end

history = Matrix{Float64}(undef, 20, length(state))
history[1, :] = state

for t in 2:20
    shock = zeros(length(state))
    if t == 8
        shock[7] = 0.12       # stress shock
        shock[4] = -0.05      # environmental shock
    end
    history[t, :] = step_system(history[t - 1, :], A; shock=shock)
end

println("Domain means across simulated trajectory:")
for (i, domain) in enumerate(domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end
