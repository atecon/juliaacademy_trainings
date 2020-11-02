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
