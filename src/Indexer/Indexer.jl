module Indexer

using NetcdfIO: read_nc, size_nc, varname_nc
using PkgUtility.DataIO: read_csv
using PkgUtility.MathTools: gapfill_data!, nanmax, nanmean, regrid, resample
using PkgUtility.PrettyDisplay: pretty_display!
using PkgUtility.RecursiveTools: NaN_test

using ..Collector: download_dataset!


# load the CO2 datasets
CCS_1Y = read_csv("$(@__DIR__)/../../data/CO2-1Y.csv");
CCS_1M = read_csv("$(@__DIR__)/../../data/CO2-1M.csv");


include("dataset-index.jl");
include("dataset-read.jl");

include("emerald-co2.jl");
include("emerald-clm.jl");
include("emerald-land-datasets.jl");
include("emerald-weather-drivers.jl");

include("grid-dict.jl");
include("grid-weather.jl");


end; # module
