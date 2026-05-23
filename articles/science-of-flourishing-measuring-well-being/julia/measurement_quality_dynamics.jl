# Measurement quality and flourishing dynamics scaffold.
#
# Synthetic demonstration only. Not for clinical, employment, public-benefits,
# or individual assessment use.

using Statistics
using Random

Random.seed!(42)

quality_domains = [
    "reliability",
    "validity",
    "cultural_comparability",
    "temporal_sensitivity",
    "use_validity"
]

quality = [0.82, 0.78, 0.62, 0.70, 0.74]

function measurement_quality_score(q)
    return mean(q)
end

function update_quality(q; investment=zeros(length(q)), drift=zeros(length(q)))
    next_q = 0.92 .* q .+ investment .- drift
    return clamp.(next_q, 0.0, 1.0)
end

history = Matrix{Float64}(undef, 24, length(quality))
history[1, :] = quality

for t in 2:24
    investment = zeros(length(quality))
    drift = zeros(length(quality))

    if t == 6
        investment[3] = 0.10  # cultural adaptation investment
        investment[5] = 0.06  # use-validity review
    end

    if t == 14
        drift[4] = 0.06       # temporal sensitivity concern
        drift[5] = 0.05       # applied-context drift
    end

    if t == 18
        investment[2] = 0.07  # validity study
        investment[4] = 0.07  # longitudinal validation
    end

    history[t, :] = update_quality(history[t - 1, :]; investment=investment, drift=drift)
end

println("Measurement quality domain means across simulated trajectory:")
for (i, domain) in enumerate(quality_domains)
    println(domain, ": ", round(mean(history[:, i]), digits=3))
end

scores = [measurement_quality_score(history[t, :]) for t in 1:size(history, 1)]
println("\nMean measurement quality score: ", round(mean(scores), digits=3))
println("Final measurement quality score: ", round(scores[end], digits=3))
