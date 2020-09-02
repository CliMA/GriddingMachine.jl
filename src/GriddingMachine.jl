module GriddingMachine

using DocStringExtensions
using HTTP
using NetCDF
using Pkg.Artifacts




# export public types
export MeanMonthlyLAI




#export public functions
export mean_LAI_map,
       read_LAI




# include the types
include("Datasets/Artifacts.jl"  )
include("Datasets/DatasetType.jl")

# The Util functions
include("Utils/lat_lon_index.jl")

# include LAI function
include("LAI/LAI.jl")




end # module
