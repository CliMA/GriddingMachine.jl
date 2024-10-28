module Collector

using Downloads
using HTTP
using JSON

using Pkg.PlatformEngines: unpack

using ..GriddingMachine: artifact_downloaded, artifact_exists, artifact_file, artifact_folder, artifact_tags, cache_folder, public_folder, tarball_file, tarball_folder, update_database!


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-25: add function to update the database
#     2024-Oct-28: make sure tarball folder exists before downloading
#     2024-Oct-28: use GriddingMachine database functions to determine if the artifact exists
#
#######################################################################################################################################################################################################
"""

    download_artifact!(arttag::String; server::String = "http://tropo.gps.caltech.edu", port::Int = 5055)

Download and unpack the artifact from the server (if file does not exist) and return the file path, given
- `arttag` GriddingMachine artifact tag
- `server` Server address (default: "http://tropo.gps.caltech.edu")
- `port` Server port (default: 5055)

"""
function download_artifact!(arttag::String; server::String = "http://tropo.gps.caltech.edu", port::Int = 5055)
    # determine if the artifact already exists in the database. If not, update the database
    # if the artifact still does not exist, return error
    if !artifact_exists(arttag)
        update_database!();
        if !artifact_exists(arttag)
            return error("Artifact $arttag does not exist in the database, please check the website for the available artifacts!")
        end;
    end;

    # get the SHA and folder of the artifact
    # if the artifact already downloaded, return the netCDF location
    art_folder = artifact_folder(arttag);
    art_file = artifact_file(arttag);
    gmt_file = joinpath(art_folder, "GRIDDINGMACHINE");
    if artifact_downloaded(arttag) && isdir(art_folder) && isfile(art_file) && isfile(gmt_file)
        return art_file
    end;

    # if the artifact is not yet downloaded, make a request to the server to ask for the url of the artifact
    web_url = "$(server):$(port)/artifact.json?artifact=$(arttag)";
    web_response = HTTP.get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = JSON.parse(json_str);

    # if there is no url in the Dictionary, return error
    if haskey(json_dict, "error")
        return error("Artifact $arttag does not exist on the server, please check the website for the available artifacts!")
    end;

    # determine if the file exists already. If not, download the artifact
    mkpath(tarball_folder(json_dict));
    tarball_file = joinpath(tarball_folder(json_dict), "$arttag.tar.gz");
    if !isfile(tarball_file)
        @info "Downloading the tarball for artifact $arttag...";
        cache_file = joinpath(cache_folder(), "$arttag.tar.gz");
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
end;


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: redo function to clean local folder rather than Julia artifact folder
#     2024-Oct-28: remove the method that use outdated GriddedCollection structure
#
#######################################################################################################################################################################################################
"""

    clean_database!(selection::String="old")

This method cleans up all selected artifacts of GriddingMachine.jl (through identify the `GRIDDINGMACHINE` file in the artifacts), given
- `selection`
    - A string indicating which artifacts to clean up
        - `old` Artifacts from an old version of GriddingMachine.jl (default)
        - `all` All Artifacts from GriddingMachine.jl
    - A vector of artifact names

---
# Examples
```julia
clean_database!();
clean_database!("old");
clean_database!("all");
clean_database!(["PFT_2X_1Y_V1"]);
```

"""
function clean_database! end

clean_database!(selection::String = "old") = (
    # iterate through the artifacts and remove the old one that is not in current Artifacts.toml or remove all artifacts within GriddingMachine.jl
    public_dirs = readdir(public_folder());
    tarball_dirs = readdir(tarball_folder());

    # if remove all artifacts
    if selection == "all"
        for fn in public_dirs
            rm(joinpath(public_folder(), fn); recursive=true, force=true);
        end;
        for fn in tarball_dirs
            rm(joinpath(tarball_folder(), fn); recursive=true, force=true);
        end;

        return nothing
    end;

    # otherwise, remove the old artifacts (update database first)
    # TODO: loop through the folder and remove the old artifacts
    update_database!();
    for arthash in public_dirs
        if !artifact_exists(arthash)
            rm(joinpath(public_folder(), arthash); recursive=true, force=true);
        end;
    end;

    return nothing
);

clean_database!(arttags::Vector{String}) = (
    # iterate the artifact hashs to remove corresponding folder
    for arttag in arttags
        rm(artifact_folder(arttag); recursive = true, force = true);
        rm(tarball_file(arttag); recursive = true, force = true);
    end;

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-28: redesign the function to sync the database
#
#######################################################################################################################################################################################################
function sync_database!()
    # update the database
    update_database!();

    # loop through the database and download the artifacts (sleep 1 second between each download)
    for arttag in artifact_tags()
        download_artifact!(arttag);
        sleep(1);
    end;

    return nothing
end;


end # module
