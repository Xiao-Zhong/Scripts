import Plots

# Plots.plotly()
# Plots.scatter(rand(10), rand(10), title="My Plot1")

# Plots.plot(rand(5,5),linewidth=2,title="My Plot2")
#
# Plots.plot(rand(10,10),linewidth=2,title="My Plot3")

using Colors
palette = distinguishable_colors(10)
println(palette)
Plots.plot(palette)
