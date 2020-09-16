module GriddingMachine

using ArchGDAL
using DocStringExtensions
using HTTP
using NetCDF
using Pkg.Artifacts




# export public types
export CanopyHeightGLAS,
       ClumpingIndexMODIS,
       GPPMPIv006,
       GPPVPMv20,
       GriddedDataset,
       LAIMonthlyMean,
       LeafNitrogen,
       LeafPhosphorus,
       LeafSLA,
       VcmaxOptimalCiCa




#export public functions
export lat_ind,
       load_LUT,
       lon_ind,
       read_LUT




# include the types
include("Datasets/DatasetType.jl")

# The Util functions
include("Utils/lat_lon_index.jl")

# load and read datasets
include("load.jl")
include("read.jl")




end # module
