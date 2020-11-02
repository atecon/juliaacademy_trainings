using Pkg;
Pkg.activate("Project.toml");
Pkg.status()

using DataFrames
using Statistics
using PyPlot
using GLM
using Printf
using Plots


# input matrix
aq = [10.0   8.04  10.0  9.14  10.0   7.46   8.0   6.58
       8.0   6.95   8.0  8.14   8.0   6.77   8.0   5.76
      13.0   7.58  13.0  8.74  13.0  12.74   8.0   7.71
       9.0   8.81   9.0  8.77   9.0   7.11   8.0   8.84
      11.0   8.33  11.0  9.26  11.0   7.81   8.0   8.47
      14.0   9.96  14.0  8.1   14.0   8.84   8.0   7.04
       6.0   7.24   6.0  6.13   6.0   6.08   8.0   5.25
       4.0   4.26   4.0  3.1    4.0   5.39  19.0  12.50 
      12.0  10.84  12.0  9.13  12.0   8.15   8.0   5.56
       7.0   4.82   7.0  7.26   7.0   6.42   8.0   7.91
       5.0   5.68   5.0  4.74   5.0   5.73   8.0   6.89];

df = DataFrame(aq);

# "string.([]) defines a string array
column_names = vec(string.(["x", "y"], [1 2 3 4]))
rename!(df, column_names)
# Alternative labeling on the fly
DataFrame(aq, vec(string.(["x", "y"], [1 2 3 4])))

# Access columns
df.y1
df[:, :x1]
df[:, [:y1, :x1]]
df[:, ["y1", "x1"]]

# Access columns by variable names
some_name = :x1
df[:,some_name]

# Reorder columns by x* followed y* columns
df2 = select(df, r"x", :)
df2

# Describe
describe(df)
describe(df, :mean, :std)
describe(df, :avg => mean, :sd => std)
describe(df, "avg" => mean, "sd" => std) # string-symbol duality again also here

describe(df, cols=[:y1, :x4], "avg" => mean, "sd" => std)

nrow(df)
ncol(df)

# Add columns
df.id = 1:nrow(df)

# New df having id as first column and "y4" second
select(df, ["id", "y4"], :)

# DF to matrix
Matrix(df)

# Prepare things for plotting
"""
Get the minima and maxima of df, and subtract and add some constant.
"""
function get_limits(df::DataFrame, variable_identifier::String, lower_padding::Int=-1, upper_padding::Int=1)::Array
    if @isdefined variable_identifier
       # df_selected = select(df, r"@sprintf(\"%s\", variable_identifier)") --> does not work
        if variable_identifier == "x"
            df_selected = select(df, r"x")
        elseif variable_identifier == "y"
            df_selected = select(df, r"y")
        end
        lim = collect(extrema(Matrix(df_selected))) .+ (lower_padding, upper_padding) # collect() casts a tuple to a vector       
    else
        lim = collect(extrema(Matrix(df))) .+ (lower_padding, upper_padding) # collect() casts a tuple to a vector       
    end
    return lim
end

# Construct limits for "y" and "x"
var_names = ["y", "x"]
limits = Dict()
for var in var_names
    limits[var] = get_limits(df, var)
end
println(limits)

# Actual plotting
p1 = Plots.plot(df.x1, df.y1, xlabel="This one is labelled", lw=3, title="Subtitle") # Make a line plot
p2 = Plots.scatter(df.x1, df.y1) # Make a scatter plot
p3 = Plots.histogram(df.x1, df.y1)
Plots.plot(p1, p2, p3, layout=(3, 1), legend=false)

