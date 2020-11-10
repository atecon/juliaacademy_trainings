using Pkg;
Pkg.activate("Project.toml");
Pkg.status()
using CSV
using Printf
using DataFrames
using Pipe
using FreqTables
using Statistics

ENV["LINES"], ENV["COLUMNS"] = 15, 15

df = CSV.File("auto2.csv") |> DataFrame

gdf = groupby(df, :brand)  # gdf has an index now

@time gdf[("ford",)]     # look-ups are very fast
# @time filter(:brand => ==("ford"), df) # much slower

# Cool for gretl too
@time brand_mpg = combine(gdf, :mpg => mean => :avg_mpg, :mpg => std)

sort!(brand_mpg, :avg_mpg, rev=true)

# Cool for gretl too
freqtable(df, :brand, :horsepower)
freqtable(df, :brand, :origin)

# Use advanced piping
orig_brand = @pipe df |>
                groupby(_, :brand) |>
                combine(_, :origin => x -> length(unique(x)))

orig_brand2 = @pipe df |>
            groupby(_, [:origin, :brand]) |>
            combine(_, nrow)

# wide to long format
origin_vs_brand = unstack(orig_brand2, :brand, :origin, :nrow)

# Replace all missing values
coalesce.(origin_vs_brand, 0)

