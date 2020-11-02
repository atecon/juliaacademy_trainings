using Pkg;
Pkg.activate("Project.toml");
Pkg.status()
using CSV
using Printf
using DataFrames


URL = "https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data-original"
FILENAME = "auto.txt"

function download_file(url::String, filename::String)
    try
        download(url, filename)
        @info(@sprintf("Succesfully downloaded file '%s'", url))
    catch e
        @warn(@sprintf("Failed to download file '%s'", url))
    end
end

download_file(URL, FILENAME)

println(readlines(FILENAME))


function read_file(filename::String)::String
    return read(filename, String)
end

raw_str = read_file(FILENAME)

# replace Tab by some other delimiter
DELIMITER = " "  # somehow ';' or ',' does not work
str_no_tab = replace(raw_str, '\t' => DELIMITER);

# Create a n IO-Buffer such that we can stream the string into an CSV file
io = IOBuffer(str_no_tab)

function str_to_csv_to_dataframe(buffer, delimiter::String)::DataFrame
    df = CSV.File(buffer,
                 delim=delimiter,
                 ignorerepeated=true,
                 header=[:mpg, :cylinders, :displacement, :horsepower,
                 :weight, :acceleration, :year, :origin, :name],
                 missingstring="NA") |>
    DataFrame

    return df
end;

df = str_to_csv_to_dataframe(io, DELIMITER)
df[:,"mpg"]
df[:,:name]
names(df)

# Number of total missings
@time sum(count(ismissing, col) for col in eachcol(df))
@time count(ismissing, Matrix(df)) # faster
@time mapcols(x -> count(ismissing, x), df)

filter(row -> any(ismissing, row), df)

# Parse the brand name from 'name' where it is the first element
# Run element-wise ops by 'split.' and 'first.'
df.brand = first.(split.(df.name, " "));

# Drop missings
df2 = dropmissing(df)
@printf("%d rows were dropped.", (nrow(df) - nrow(df2)))

# Filter
df2[df2.brand .== "saab", :] # via indexing
filter(:brand => ==("saab"), df2)

exit()