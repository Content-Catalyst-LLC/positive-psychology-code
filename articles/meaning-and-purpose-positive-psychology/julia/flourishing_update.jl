# Toy flourishing dynamic update model.

flourishing = 0.50
support = 0.72
intervention = 0.40
stress = 0.30
recovery_rate = 0.08

for t in 1:12
    flourishing = flourishing + recovery_rate * (0.35 * support + 0.25 * intervention - 0.30 * stress)
    flourishing = clamp(flourishing, 0.0, 1.0)
    println("Time ", t, ": flourishing = ", round(flourishing, digits=3))
end
