using JSON;

include("EmeraldIO.jl");
include("EmeraldUtility.jl");

include("json_copied/data_read.jl");
include("json_copied/data_reprocess.jl");
include("json_copied/deploy.jl");
include("json_copied/json_attribute.jl");
include("json_copied/json_data.jl");
include("json_copied/json_griddingmachine.jl");
include("json_copied/json_map.jl");
include("json_copied/json_save.jl");

#GRIDDING_MACHINE_HOME = "/home/exgu/GriddingMachine.jlfdf";
#ARTIFACT_TOML         = "$(GRIDDING_MACHINE_HOME)/Artifacts.toml";
#DATASET_FOLDER        = "$(GRIDDING_MACHINE_HOME)/reprocessed";
#ARTIFACT_FOLDER       = "$(GRIDDING_MACHINE_HOME)/artifacts"
FTP_URLS              = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];