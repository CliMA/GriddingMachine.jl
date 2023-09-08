using JSON
using ArchGDAL: read, getband

GRIDDING_MACHINE_HOME = "$(homedir())/GriddingMachine";
ARTIFACT_TOML         = "$(GRIDDING_MACHINE_HOME)/Artifacts.toml";
DATASET_FOLDER        = "$(GRIDDING_MACHINE_HOME)/reprocessed";
ARTIFACT_FOLDER       = "$(GRIDDING_MACHINE_HOME)/artifacts";
FTP_URLS              = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];

include("process_json/deploy.jl")
include("process_json/data_read.jl")
include("process_json/data_reprocess.jl")
include("process_json/json_attribute.jl")
include("process_json/json_data.jl")
include("process_json/json_griddingmachine.jl")
include("process_json/json_map.jl")
include("process_json/json_save.jl")

include("geotiff/read.jl")
