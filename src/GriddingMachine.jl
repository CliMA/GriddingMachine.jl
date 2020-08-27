module GriddingMachine

using DocStringExtensions
using NetCDF




# export public types
export MeanMonthlyLAI




#export public functions
export mean_LAI_map,
       read_LAI




# include the types
include("DatasetType.jl")

# The Util functions
include("Utils/lat_lon_index.jl")

# include LAI function
include("LAI/LAI.jl")




end # module
