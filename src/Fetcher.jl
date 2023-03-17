module Fetcher

using Conda: add
using Dates: isleapyear
using DocStringExtensions: TYPEDEF, METHODLIST
using PkgUtility: month_days
using ProgressMeter: @showprogress
using PyCall: pyimport


# ERA5 related information
CDSAPI_PORTAL  = "https://cds.climate.copernicus.eu/api/v2";
CDSAPI_KEY     = "";
CDSAPI_CLIENT  = nothing;
MODIS_USER_ID  = "";
MODIS_USER_PWD = "";


include("fetcher/era5.jl"    )
include("fetcher/modis.jl"   )
include("fetcher/password.jl")


end # module
