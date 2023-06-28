module Fetcher

using Conda: add
using Dates: isleapyear
using DocStringExtensions: TYPEDEF, TYPEDFIELDS, METHODLIST
using ProgressMeter: @showprogress
using PyCall: pyimport

export GeneralWgetData
export fetch_data!


# ERA5 related information
CDSAPI_PORTAL  = "https://cds.climate.copernicus.eu/api/v2";
CDSAPI_KEY     = "";
CDSAPI_CLIENT  = nothing;
EARTH_DATA_ID  = "";
EARTH_DATA_PWD = "";


# the functions below are borrowed from Yujie's Emerald repo to avoid inter-dependency
include("borrowed/EmeraldUtility.jl")


# include the function files
include("fetcher/general.jl");
include("fetcher/password.jl");

include("fetcher/carbontracker.jl");
include("fetcher/era5.jl");
include("fetcher/gedi.jl");
include("fetcher/modis.jl");
include("fetcher/smap.jl");


end # module
