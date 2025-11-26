module Fetcher

using Dates: isleapyear
using DocStringExtensions: TYPEDEF, TYPEDFIELDS
using PkgUtility.TimeParser: MDAYS, MDAYS_LEAP, which_month
using ProgressMeter: @showprogress

export GeneralWgetData
export fetch_data!


# EarthData related information
EARTH_DATA_ID  = "";
EARTH_DATA_PWD = "";


# include the function files
include("fetcher/general.jl");
include("fetcher/password.jl");

include("fetcher/carbontracker.jl");
include("fetcher/gedi.jl");
include("fetcher/modis.jl");
include("fetcher/smap.jl");
include("fetcher/viirs.jl");


end # module
