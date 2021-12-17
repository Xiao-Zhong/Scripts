using VegaLite, DataFrames, Query, VegaDatasets
using Plots

cars = dataset("cars")

cars |> @select(:Acceleration, :Name) |> collect

plot(1:10)