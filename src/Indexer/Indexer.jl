module Indexer

using NetcdfIO: read_nc, size_nc, varname_nc

using ..Collector: download_dataset!


include("dataset-read.jl");
include("lat-lon-index.jl");


end; # module
