module Collector

using Downloads
using PkgUtility.ArtifactTools: read_library

using ..GriddingMachine: GRIDDINGMACHINE_HOME


# download the Artifacts.yaml file from Zenodo and then decode it
YAML_URL = "https://zenodo.org/records/15622411";
YAML_FILE = joinpath(homedir(), "GriddingMachine", "Artifacts.yaml");
ZENODO_FILE = joinpath(homedir(), "GriddingMachine", "Zenodo");
ZENODO_RECORD = isfile(ZENODO_FILE) ? readline(ZENODO_FILE) : nothing;


# function to update the database
include("database-clean.jl");
include("database-download.jl");
include("database-load.jl");
include("database-sync.jl");
include("database-tree.jl");
include("database-update.jl");

include("dataset-download.jl");
include("dataset-info.jl");


# load the database at the first time
YAML_DATABASE, YAML_SHAS, YAML_TAGS = load_database!();


end # module
