module Requestor

using Artifacts: load_artifacts_toml
using DataFrames: DataFrame
using HTTP: get
using JSON: parse

export request_site_data


include("requestor/gm_artifact.jl");
include("requestor/gm_dict.jl");
include("requestor/gm_weather.jl");


end; # module
