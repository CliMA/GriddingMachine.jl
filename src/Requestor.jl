module Requestor

using Artifacts: load_artifacts_toml
using HTTP: get
using JSON: parse

using ..GriddingMachine: GM_DIR, META_INFO, META_TAGS

export request_LUT


include("requestor/gm_artifact.jl");
include("requestor/gm_dict.jl");


end; # module
