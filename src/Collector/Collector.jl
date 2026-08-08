module Collector

using Downloads
using HTTP
using SHA
using PkgUtility.ArtifactTools: read_library

export CatalogValidationError, clean_database!, configure!, dataset_cache, dataset_dir,
    dataset_found, dataset_info, dataset_path, dataset_url, download_database!,
    download_dataset!, initialize_database!, latest_datasets, load_database!,
    local_datasets, sync_database!, update_database!, validate_catalog,
    verify_dataset_file

GRIDDINGMACHINE_HOME = ""
YAML_URL = ""
YAML_FILE = ""
const YAML_DATABASE = Dict{String,Any}()
const YAML_TAGS = String[]

"""Configure the local data root and external catalog without performing network I/O."""
function configure!(;
        home::AbstractString = get(ENV, "GRIDDING_MACHINE_HOME", joinpath(homedir(), "GriddingMachine")),
        catalog_url::AbstractString = get(ENV, "GRIDDING_MACHINE_CATALOG_URL", "https://zenodo.org/records/15622411"),
        catalog_file::AbstractString = get(ENV, "GRIDDING_MACHINE_CATALOG_FILE", joinpath(home, "Artifacts.yaml")),
        clear::Bool = true,
    )
    global GRIDDINGMACHINE_HOME = abspath(home)
    global YAML_URL = String(catalog_url)
    global YAML_FILE = abspath(catalog_file)
    if clear
        empty!(YAML_DATABASE)
        empty!(YAML_TAGS)
    end
    return nothing
end

function __init__()
    configure!()
end


# function to update the database
include("database-clean.jl");
include("database-schema.jl");
include("database-download.jl");
include("database-initialize.jl");
include("database-load.jl");
include("database-sync.jl");
include("database-tree.jl");
include("database-update.jl");

include("dataset-download.jl");
include("dataset-info.jl");


end # module
