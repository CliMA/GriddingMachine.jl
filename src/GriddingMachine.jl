module GriddingMachine

using ArchGDAL
using DocStringExtensions
using HTTP
using NetCDF
using Parameters
using Pkg.Artifacts
using ProgressMeter




# export public types
export AbstractDataset,
       AbstractCanopyHeight,
       AbstractClumpingIndex,
       AbstractGPP,
       AbstractLAI,
       AbstractLeafMN,
       AbstractNPP,
       AbstractVcmax,
       CanopyHeightGLAS,
       ClumpingIndexMODIS,
       ClumpingIndexPFT,
       FormatNC,
       FormatTIFF,
       GPPMPIv006,
       GPPVPMv20,
       GriddedDataset,
       LAIMonthlyMean,
       LeafNitrogen,
       LeafPhosphorus,
       LeafSLA,
       NPPModis,
       VcmaxOptimalCiCa




#export public functions
export lat_ind,
       load_LUT,
       lon_ind,
       mask_LUT!,
       query_LUT,
       read_LUT,
       regrid_LUT




# include the types
include("Datasets/DatasetType.jl")
include("Datasets/FormatType.jl" )
include("Datasets/load.jl"       )
include("Datasets/mask.jl"       )
include("Datasets/query.jl"      )
include("Datasets/read.jl"       )
include("Datasets/regrid.jl"     )

# The Util functions
include("Utils/lat_lon_index.jl")




end # module
