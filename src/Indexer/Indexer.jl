module Indexer

using NetcdfIO: read_nc, size_nc, varname_nc
using PkgUtility.MathTools: gapfill_data!, nanmax, nanmean, regrid
using PkgUtility.PrettyDisplay: pretty_display!
using PkgUtility.TextIO: read_csv

using ..Collector: download_dataset!


# load the CO2 datasets
CCS_1Y = read_csv("$(@__DIR__)/../../data/CO2-1Y.csv");
CCS_1M = read_csv("$(@__DIR__)/../../data/CO2-1M.csv");


include("dataset-read.jl");
include("emerald-clm.jl");
include("emerald-co2.jl");
include("emerald-dataset.jl");
include("emerald-grid-dict.jl");
include("lat-lon-index.jl");


end; # module
