module Collector

using Downloads
using HTTP
using JSON
using YAML

using DocStringExtensions: TYPEDEF, TYPEDFIELDS
using Pkg.PlatformEngines: unpack

using ..GriddingMachine: GRIDDINGMACHINE_HOME, YAML_FILE, YAML_URL
import ..GriddingMachine: YAML_DATABASE, YAML_SHAS, YAML_TAGS

export query_collection


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-25: add function to update the database
#     2024-Oct-28: make sure tarball folder exists before downloading
#
#######################################################################################################################################################################################################
"""

    update_database!()

Update the database of GriddingMachine.jl

"""
function update_database!()
    download_yaml_file = retry(delays = fill(1.0, 3)) do
        Downloads.download(YAML_URL, YAML_FILE);
    end;
    download_yaml_file();

    global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
    YAML_DATABASE = YAML.load_file(YAML_FILE);
    YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
    YAML_TAGS = [k for k in keys(YAML_DATABASE)];

    return nothing
end;


function download_artifact! end;

download_artifact!(arttag::String; server::String = "http://tropo.gps.caltech.edu", port::Int = 5055) = (
    # warning if the artifact is not in current database
    if !(arttag in YAML_TAGS)
        printstyled("Warning: Artifact $arttag is not in current database, possible reasons are:\n", color = :yellow);
        printstyled("    1. The Artifact.yaml file is not up-to-date, please run `Collector.update_database!()`!\n", color = :yellow);
        printstyled("    2. The artifact is not available on the server, please check the website for the available artifacts!\n", color = :yellow);
    end;

    # get the SHA and folder of the artifact
    sha = YAML_DATABASE[arttag]["SHA"];
    art_folder = joinpath(GRIDDINGMACHINE_HOME, "public", sha);
    art_file = joinpath(art_folder, "$arttag.nc");
    gmt_file = joinpath(art_folder, "GRIDDINGMACHINE");

    # if the artifact already exists, return the netCDF location
    if arttag in YAML_TAGS && isdir(art_folder) && isfile(art_file) && isfile(gmt_file)
        @info "Artifact $arttag already exists locally, returning the netCDF file location";
        return art_file
    end;

    # make a request to the server to ask for the url of the artifact
    web_url = "$(server):$(port)/artifact.json?artifact=$(arttag)";
    web_response = HTTP.get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = JSON.parse(json_str);

    # if there is no url in the Dictionary, return error
    if haskey(json_dict, "error")
        return error("Artifact $arttag does not exist on the server, please check the website for the available artifacts!")
    end;

    # determine if the file exists already. If not, download the artifact
    tarball_folder = joinpath(GRIDDINGMACHINE_HOME, "tarballs", json_dict["folder"]);
    mkpath(tarball_folder);
    tarball_file = joinpath(tarball_folder, "$arttag.tar.gz");
    if !isfile(tarball_file)
        @info "Downloading the tarball for artifact $arttag...";
        cache_file = joinpath(GRIDDINGMACHINE_HOME, "cache", "$arttag.tar.gz");
        Downloads.download(json_dict["url"], cache_file);
        mv(cache_file, tarball_file);
    end;

    # unpack the tarball
    @info "Unpacking the tarball for artifact $arttag..." art_file art_folder tarball_file gmt_file;
    try
        unpack(tarball_file, art_folder);
    catch e
        rm(art_folder; recursive=true, force=true);
        return error("Failed to unpack the tarball for artifact $arttag")
    end;

    return art_file
);

query_collection = download_artifact!;


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: redo function to clean local folder rather than Julia artifact folder
#     2024-Oct-28: remove the method that use outdated GriddedCollection structure
#
#######################################################################################################################################################################################################
"""

    clean_collections!(selection::String="old")

This method cleans up all selected artifacts of GriddingMachine.jl (through identify the `GRIDDINGMACHINE` file in the artifacts), given
- `selection`
    - A string indicating which artifacts to clean up
        - `old` Artifacts from an old version of GriddingMachine.jl (default)
        - `all` All Artifacts from GriddingMachine.jl
    - A vector of artifact names

---
# Examples
```julia
clean_collections!();
clean_collections!("old");
clean_collections!("all");
clean_collections!(["PFT_2X_1Y_V1"]);
```

"""
function clean_collections! end

clean_collections!(selection::String = "old") = (
    # iterate through the artifacts and remove the old one that is not in current Artifacts.toml or remove all artifacts within GriddingMachine.jl
    artifact_dirs = readdir("$(GRIDDINGMACHINE_HOME)/public");

    # if remove all artifacts
    if selection == "all"
        for arthash in artifact_dirs
            rm("$(GRIDDINGMACHINE_HOME)/public/$(arthash)"; recursive=true, force=true);
        end;

        return nothing
    end;

    # otherwise, remove the old artifacts (update database first)
    update_database!();
    for arthash in artifact_dirs
        if !(arthash in YAML_SHAS)
            rm("$(GRIDDINGMACHINE_HOME)/public/$(arthash)"; recursive=true, force=true);
        end;
    end;

    return nothing
);

clean_collections!(arttags::Vector{String}) = (
    # iterate the artifact hashs to remove corresponding folder
    for arttag in arttags
        arthash = YAML_DATABASE[arttag]["SHA"];
        rm("$(GRIDDINGMACHINE_HOME)/public/$(arthash)"; recursive=true, force=true);
    end;

    return nothing
);


#=
#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
"""

    sync_collections!()
    sync_collections!(gcs::GriddedCollection)

Sync collection datasets to local drive, given
- `gc` [`GriddedCollection`](@ref) type collection

"""
function sync_collections! end

sync_collections!(gc::GriddedCollection) = (
    for tagver in gc.SUPPORTED_COMBOS
        query_collection(gc, tagver);
    end;

    return nothing
);

sync_collections!() = (
    # loop through all datasets

    return nothing
);
=#


end # module
