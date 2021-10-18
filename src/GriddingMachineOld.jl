module GriddingMachineOld

using Conda
using Dates
using LazyArtifacts

using DataFrames: DataFrame
using Distributed: @everywhere, addprocs, pmap, rmprocs, workers
using DocStringExtensions: FIELDS
using Glob: glob
using PkgUtility: month_days, nanmean, predownload_artifact!, read_csv, read_nc, save_csv!, save_nc!
using ProgressMeter: @showprogress
using PyCall: pyimport
using UnPack: @unpack

using ..Indexer: lat_ind, lon_ind




# global constants
ARTIFACTs_TOML = joinpath(@__DIR__, "../Artifacts.toml");
MODIS_HOME     = "/net/fluo/data1/data/MODIS";
MODIS_PORTAL   = "https://e4ftl01.cr.usgs.gov";
MODIS_USER_ID  = "";
MODIS_USER_PWD = "";




# export public types for GriddedDataset
export GriddedDataset

# export public types for UngriddedDataset
export MOD09A1v006NIRv, MOD15A2Hv006LAI

#export public functions for GriddedDataset
export regrid_LUT, save_LUT!

#export public functions for UngriddedDataset
export process_RAW!




# include functions to load/read datasets
include("Datasets/DatasetType.jl")
include("Datasets/regrid.jl"     )
include("Datasets/save.jl"       )

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
include("Utils/password.jl")




end # module
