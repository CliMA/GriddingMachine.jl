module GriddingMachine

using ArchGDAL
using Conda
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
using PyCall
using Statistics




# global constants
ARTIFACTs_TOML = joinpath(@__DIR__, "../Artifacts.toml");
CDSAPI_PORTAL  = "https://cds.climate.copernicus.eu/api/v2";
CDSAPI_KEY     = "";
CDSAPI_CLIENT  = nothing;
MODIS_GRID_LAT = nothing;
MODIS_GRID_LON = nothing;
MODIS_HOME     = "/net/fluo/data1/data/MODIS";
MODIS_PORTAL   = "https://e4ftl01.cr.usgs.gov";
MODIS_USER_ID  = "";
MODIS_USER_PWD = "";




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
       LAIMODISv006,
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

# export public types for ERA5Dataset
export AbstractERA5Data,
       ERA5LandHourly

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

#export public functions for UngriddedDataset
export compile_RAW!,
       dynamic_workers!,
       fetch_RAW!,
       grid_RAW!,
       load_MODIS!,
       parse_HV,
       process_RAW!,
       query_RAW

# export public functions for ERA5Dataset
export fetch_ERA5!




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

# include function for ERA5 datasets
include("ERA5/DataType.jl")
include("ERA5/fetch.jl"   )

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
include("Utils/cdsapi.jl"       )
include("Utils/lat_lon_index.jl")
include("Utils/password.jl"     )




end # module
