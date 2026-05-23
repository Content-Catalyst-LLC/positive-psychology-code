# Systems simulation scaffold for well-being and sustainable development.
#
# Synthetic demonstration only. Not for clinical, employment, or individual assessment use.

using LinearAlgebra
using Statistics
using Random

Random.seed!(42)

domains = [
    "capabilities",
    "subjective_wellbeing",
    "institutions",
    "ecology",
    "security_services",
    "resilience",
    "inequality"
]

state = [0.68, 0.66, 0.64, 0.61, 0.65, 0.63, 0.42]

# Supportive domains reinforce one another; inequality and ecological stress reduce resilience.
A = [
    0.82 0.04 0.05 0.03 0.06 0.04 -0.06;
    0.05 0.80 0.05 0.03 0.05 0.05 -0.06;
    0.05 0.04 0.84 0.05 0.06 0.06 -0.08;
    0.03 0.03 0.05 0.86 0.04 0.05 -0.04;
    0.06 0.04 0.06 0.03 0.84 0.05 -0.06;
    0.04 0.05 0.06 0.05 0.05 0.82 -0.07;
    -0.04 -0.04 -0.05 -0.03 -0.05 -0.05 0.80
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
        shock[4] = -0.10   # ecological shock
        shock[7] = 0.08    # inequality burden increases
    end
    if t == 14
        shock[3] = 0.08    # governance investment
        shock[6] = 0.06    # resilience investment
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
