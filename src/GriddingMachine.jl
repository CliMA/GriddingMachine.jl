module GriddingMachine

using DocStringExtensions
using HTTP
using NetCDF
using Pkg.Artifacts




# export public types
export MeanMonthlyLAI,
       VPMGPPv20




#export public functions
export load_LUT,
       read_LUT




# include the types
include("Datasets/DatasetType.jl"   )

# The Util functions
include("Utils/lat_lon_index.jl")

# load and read datasets
include("load.jl")
include("read.jl")




end # module
