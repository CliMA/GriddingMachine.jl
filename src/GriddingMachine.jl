module GriddingMachine

using DocStringExtensions
using HTTP
using NetCDF
using Pkg.Artifacts




# export public types
export MeanMonthlyLAI




#export public functions
export read_LUT




# include the types
include("Datasets/Artifacts.jl"  )
include("Datasets/DatasetType.jl")

# The Util functions
include("Utils/lat_lon_index.jl")

# load and read datasets
include("read.jl")




end # module
