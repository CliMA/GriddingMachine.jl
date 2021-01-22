module GriddingMachine

using ArchGDAL
using CSV
using DataFrames
using Dates
using Distributed
using DocStringExtensions
using Glob
using NetCDF
using Parameters
using Pkg.Artifacts
using ProgressMeter
using Statistics




# global MODIS grid information to avoid repeated memory copy
MODIS_GRID_LAT = 0
MODIS_GRID_LON = 0




# export public types for GriddedDataset
export AbstractDataset,
       CanopyHeightGLAS,
       ClumpingIndexMODIS,
       ClumpingIndexPFT,
       FloodPlainHeight,
       FormatNC,
       FormatTIFF,
       GPPMPIv006,
       GPPVPMv20,
       GriddedDataset,
       LAIMonthlyMean,
       LandElevation,
       LandMaskERA5,
       LeafChlorophyll,
       LeafNitrogen,
       LeafPhosphorus,
       LeafSLA,
       NPPModis,
       RiverHeight,
       RiverLength,
       RiverManning,
       RiverWidth,
       SIFTropomi740,
       TreeDensity,
       UnitCatchmentArea,
       VcmaxOptimalCiCa,
       WoodDensity




# export public types for UngriddedDataset
export AbstractUngriddedData,
       AbstractMODIS500m,
       AbstractMODIS1km,
       MOD15A2Hv006LAI




#export public functions for GriddedDataset
export lat_ind,
       load_LUT,
       lon_ind,
       mask_LUT!,
       query_LUT,
       read_LUT,
       regrid_LUT,
       save_LUT!,
       view_LUT




#export public functions for GriddedDataset
export compile_RAW,
       dynamic_workers,
       fetch_RAW,
       grid_RAW,
       load_MODIS!,
       parse_HV,
       query_RAW




# include functions to load/read datasets
include("Datasets/DatasetType.jl")
include("Datasets/FormatType.jl" )
include("Datasets/load.jl"       )
include("Datasets/mask.jl"       )
include("Datasets/query.jl"      )
include("Datasets/read.jl"       )
include("Datasets/regrid.jl"     )
include("Datasets/save.jl"       )
include("Datasets/view.jl"       )

# include functions to grid datasets
include("Gridding/DataType.jl")
include("Gridding/compile.jl" )
include("Gridding/fetch.jl"   )
include("Gridding/grid.jl"    )
include("Gridding/load.jl"    )
include("Gridding/parse.jl"   )
include("Gridding/query.jl"   )
include("Gridding/workers.jl" )

# The Util functions
include("Utils/lat_lon_index.jl")




end # module
