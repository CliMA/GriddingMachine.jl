#######################################################################################################################################################################################################
#
# Style Guide
# 1. Types and modules start with upper case letters for each word, such as LeafBiophysics
# 2. Functions are lower case words connected using _, such as leaf_biophysics
# 3. Constants are defined using all upper cases, such as LEAF_BIOPHYSICS
# 4. Variables are defined using all lower cases, such as leaf_bio_para
# 5. Temporary variables are defined to start with _, such as _leaf
# 6. Maximum length of each line is 200 letters (including space)
# 7. There should be 2 lines of  empty lines between different components, such as two functions and methods
# 8. Bug fixes or new changes should be documented in the comments above the struct, function, or method, such as this Style Guide above Smaragdus.jl
# 9. Function parameter list that spans multiple lines need to be spaced with 12 spaces (3 tabs)
#
#######################################################################################################################################################################################################
module GriddingMachine

using Dates
using Downloads
using YAML

export Blender, Collector, Fetcher, Indexer, Requestor


# make sure the GriddingMachine directory exists
GRIDDINGMACHINE_HOME = joinpath(homedir(), "GriddingMachine");
mkpath(GRIDDINGMACHINE_HOME);
mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));
mkpath(joinpath(GRIDDINGMACHINE_HOME, "tarballs"));
mkpath(joinpath(GRIDDINGMACHINE_HOME, "cache"));


# download the Artifacts.yaml file (if not exists)
YAML_URL = "https://raw.githubusercontent.com/silicormosia/GriddingMachineDatasets/refs/heads/wyujie/Artifacts.yaml";
YAML_FILE = joinpath(homedir(), "GriddingMachine", "Artifacts.yaml");
if !isfile(YAML_FILE)
    download_yaml_file = retry(delays = fill(1.0, 3)) do
        Downloads.download(YAML_URL, YAML_FILE);
    end;
    download_yaml_file();
end;
YAML_DATABASE = YAML.load_file(YAML_FILE);
YAML_TAGS = [k for k in keys(YAML_DATABASE)];


# include submodules
include("Blender.jl");
include("Collector.jl");
include("Fetcher.jl");
include("Indexer.jl");
include("Requestor.jl");


end # module
