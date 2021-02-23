module GriddingMachine

using ArchGDAL
using CSV
using DataFrames
using Dates
using Distributed
using DocStringExtensions
using Glob
using LazyArtifacts
using NetCDF
using Parameters
using Pkg.Artifacts
using PkgUtility
using ProgressMeter
using Statistics




# global constants
MODIS_GRID_LAT = 0;
MODIS_GRID_LON = 0;
MODIS_HOME     = "/net/fluo/data1/data/MODIS";
MODIS_PORTAL   = "https://e4ftl01.cr.usgs.gov";
USER_NAME      = "";
USER_PASS      = "";
ARTIFACTs_TOML = joinpath(@__DIR__, "../Artifacts.toml");




# export public types for GriddedDataset
export AbstractDataset,
       CanopyHeightBoonman,
       CanopyHeightGLAS,
       ClumpingIndexMODIS,
       ClumpingIndexPFT,
       FormatNC,
       FormatTIFF,
       GPPMPIv006,
       GPPVPMv20,
       GriddedDataset,
       LAIMonthlyMean,
       LandMaskERA5,
       LeafNitrogenBoonman,
       LeafNitrogenButler,
       LeafPhosphorus,
       LeafSLABoonman,
       LeafSLAButler,
       NDVIAvhrr,
       NIRoAvhrr,
       NIRvAvhrr,
       NPPModis,
       SIFTropomi740,
       TreeDensity,
       VcmaxOptimalCiCa,
       VGMAlphaJules,
       VGMLogNJules,
       VGMThetaRJules,
       VGMThetaSJules,
       WoodDensity




# export public types for UngriddedDataset
export AbstractUngriddedData,
       AbstractMODIS500m,
       AbstractMODIS1km,
       MOD09A1v006NIRv,
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
export compile_RAW!,
       dynamic_workers!,
       fetch_RAW!,
       grid_RAW!,
       load_MODIS!,
       parse_HV,
       process_RAW!,
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
include("Gridding/DataType.jl" )
include("Gridding/compile.jl"  )
include("Gridding/fetch.jl"    )
include("Gridding/grid.jl"     )
include("Gridding/load.jl"     )
include("Gridding/parse.jl"    )
include("Gridding/query.jl"    )
include("Gridding/shortcuts.jl")
include("Gridding/workers.jl"  )

# The Util functions
include("Utils/date.jl"         )
include("Utils/lat_lon_index.jl")
include("Utils/password.jl"     )




end # module
