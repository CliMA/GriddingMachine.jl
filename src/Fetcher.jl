module Fetcher

using Conda: add
using Dates: isleapyear
using DocStringExtensions: TYPEDEF, TYPEDFIELDS, METHODLIST
using PkgUtility: MDAYS, MDAYS_LEAP, month_days, month_ind
using ProgressMeter: @showprogress
using PyCall: pyimport


# ERA5 related information
CDSAPI_PORTAL = "https://cds.climate.copernicus.eu/api/v2";
CDSAPI_KEY    = "";
CDSAPI_CLIENT = nothing;
WGET_USER_ID  = "";
WGET_USER_PWD = "";


include("fetcher/general.jl");
include("fetcher/password.jl");

include("fetcher/carbontracker.jl");
include("fetcher/era5.jl");
include("fetcher/modis.jl");
include("fetcher/smap.jl");


end # module
