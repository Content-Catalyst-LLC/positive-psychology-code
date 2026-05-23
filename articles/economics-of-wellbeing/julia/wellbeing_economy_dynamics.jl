# Systems simulation scaffold for the economics of well-being.
#
# Synthetic demonstration only. Not for clinical, employment, or individual assessment use.

using LinearAlgebra
using Statistics
using Random

Random.seed!(42)

domains = [
    "material_security",
    "subjective_wellbeing",
    "health",
    "social_trust",
    "institutions",
    "environment",
    "work_quality",
    "care_security",
    "inequality",
    "time_pressure"
]

state = [0.66, 0.65, 0.67, 0.63, 0.62, 0.60, 0.61, 0.60, 0.42, 0.46]

# Supportive domains reinforce one another; inequality and time pressure reduce well-being.
A = [
    0.82 0.04 0.04 0.03 0.05 0.02 0.04 0.04 -0.06 -0.04;
    0.05 0.80 0.05 0.04 0.04 0.03 0.04 0.04 -0.05 -0.05;
    0.04 0.04 0.83 0.03 0.04 0.04 0.03 0.04 -0.05 -0.05;
    0.03 0.04 0.03 0.84 0.07 0.03 0.03 0.03 -0.06 -0.03;
    0.05 0.04 0.04 0.07 0.84 0.05 0.04 0.04 -0.07 -0.04;
    0.02 0.03 0.04 0.03 0.05 0.86 0.02 0.02 -0.03 -0.02;
    0.04 0.04 0.03 0.03 0.04 0.02 0.83 0.05 -0.04 -0.06;
    0.04 0.04 0.04 0.03 0.04 0.02 0.05 0.83 -0.04 -0.05;
    -0.04 -0.04 -0.04 -0.05 -0.05 -0.03 -0.04 -0.04 0.80 0.04;
    -0.03 -0.04 -0.04 -0.03 -0.03 -0.02 -0.05 -0.05 0.04 0.79
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
        shock[9] = 0.08    # inequality shock
        shock[10] = 0.07   # time pressure shock
    end
    if t == 14
        shock[5] = 0.08    # institutional investment
        shock[8] = 0.06    # care-security investment
        shock[7] = 0.05    # work-quality investment
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
