using CSV
using DataFrames
using Statistics

panel = CSV.read("data/virtue_flourishing_panel.csv", DataFrame)

panel.flourishing_composite = mean.(eachrow(panel[:, [:meaning, :relationships, :accomplishment, :positive_emotion]]))
panel.virtue_composite = mean.(eachrow(panel[:, [:strengths_wisdom, :strengths_courage, :strengths_humanity, :strengths_justice, :strengths_temperance, :strengths_transcendence]]))

summary = combine(groupby(panel, :wave),
    :flourishing_composite => mean => :avg_flourishing,
    :virtue_composite => mean => :avg_virtue_index,
    :reflective_judgment => mean => :avg_practical_wisdom_proxy,
    :institutional_support => mean => :avg_institutional_support,
    :stress_load => mean => :avg_stress_load,
    nrow => :n_observations
)

mkpath("outputs")
CSV.write("outputs/julia_virtue_summary.csv", summary)
println(summary)
