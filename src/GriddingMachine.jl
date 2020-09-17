module GriddingMachine

using ArchGDAL
using DocStringExtensions
using HTTP
using NetCDF
using Parameters
using Pkg.Artifacts




# export public types
export CanopyHeightGLAS,
       ClumpingIndexMODIS,
       ClumpingIndexPFT,
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
       query_LUT,
       read_LUT,
       regrid_LUT




# include the types
include("Datasets/DatasetType.jl")
include("Datasets/FormatType.jl" )
include("Datasets/load.jl"       )
include("Datasets/query.jl"      )
include("Datasets/read.jl"       )
include("Datasets/regrid.jl"     )

# The Util functions
include("Utils/lat_lon_index.jl")




end # module
