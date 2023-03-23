using DataFrames
using CSV
using Plots
using DelimitedFiles
using Statistics
using Interpolations
using LinearAlgebra
using StatsBase

# Load CSV file
df = CSV.read(download("https://raw.githubusercontent.com/christopherpaine/MDD/main/Mortality_tables/HMD_UK_males_1x1.csv"), DataFrame, header=1)

# Extract x, y, and z data
x = parse.(Float64, filter(x -> x != "110+", df.Age))
y = parse.(Float64, df.Year)
z = parse.(Float64, df.qx)

# Create grid
xi = range(minimum(x), stop=maximum(x), length=100)
yi = range(minimum(y), stop=maximum(y), length=100)
xi_n, yi_n = copy(xi), copy(yi)
Xn, Yn = hcat(xi_n'), repeat(yi_n', length(xi_n)), zeros(length(xi_n), length(yi_n))

# Interpolate z data
interp = LinearInterpolation((x,y), z, extrapolation_bc=Line())
Z = zeros(length(xi_n), length(yi_n))
for i in 1:length(xi_n)
    for j in 1:length(yi_n)
        Z[i, j] = interp((xi_n[i], yi_n[j]))
    end
end

# Compute log of Z
z_log = log10.(Z)

# Create plot
heatmap(xi_n, yi_n, Z, c=z_log, color=:blues, xlabel="Age", ylabel="Year", zscale=:log10, title="Mortality Table",
        clims=(minimum(z_log), maximum(z_log)), colorbar_title="qx", colorbar_ticks=[-6, -4, -3, -2, -1, 0],
        colorbar_tick_labels=[0, 1e-4, 0.001, 0.01, 0.1, 1], colorbar_length=0.85)
