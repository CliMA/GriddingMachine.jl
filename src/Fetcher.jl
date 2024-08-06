module Fetcher

using Dates: isleapyear
using DocStringExtensions: TYPEDEF, TYPEDFIELDS
using ProgressMeter: @showprogress

export GeneralWgetData
export fetch_data!


# EarthData related information
EARTH_DATA_ID  = "";
EARTH_DATA_PWD = "";


# the functions below are borrowed from Yujie's Emerald repo to avoid inter-dependency
include("borrowed/EmeraldUtility.jl")


# include the function files
include("fetcher/general.jl");
include("fetcher/password.jl");

include("fetcher/carbontracker.jl");
include("fetcher/gedi.jl");
include("fetcher/modis.jl");
include("fetcher/smap.jl");
include("fetcher/viirs.jl");


end # module
