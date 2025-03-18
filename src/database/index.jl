#######################################################################################################################################################################################################
#
# Changes to the functions
# General
#     2024-Oct-28: add functions to get the path or folder of the artifact
#     2024-Oct-28: add function to return all the tags in the database
#     2024-Oct-28: add function to return the tarball file path
#
#######################################################################################################################################################################################################
"""

    artifact_file(arttag::String)

Returns the path of the artifact file
- `arttag` GriddingMachine artifact tag

"""
function artifact_file(arttag::String)
    return joinpath(artifact_folder(arttag), "$arttag.nc")
end;


"""

    artifact_folder(arttag::String)

Returns the path of the artifact folder, given
- `arttag` GriddingMachine artifact tag

"""
function artifact_folder(arttag::String)
    return joinpath(public_folder(), artifact_sha(arttag))
end;


"""

    artifact_sha(arttag::String)

Returns the SHA of the artifact, given
- `arttag` GriddingMachine artifact tag

"""
function artifact_sha(arttag::String)
    return YAML_DATABASE[arttag]["SHA"]
end;


"""

    artifact_tags()

Returns the tags of the artifacts

"""
function artifact_tags()
    return YAML_TAGS
end;


"""

    cache_folder()

Returns the path of the cache folder

"""
function cache_folder()
    return joinpath(GRIDDINGMACHINE_HOME, "cache")
end;


"""

    public_folder()

Returns the path of the public folder

"""
function public_folder()
    return joinpath(GRIDDINGMACHINE_HOME, "public")
end;


"""

    tarball_folder()
    tarball_folder(dict::Dict)

Returns the path of the tarball folder, given
- `dict` A dictionary of the artifact (if not given, return the tarball folder)

"""
function tarball_folder end;

tarball_folder() = joinpath(GRIDDINGMACHINE_HOME, "tarballs");

tarball_folder(arttag::String) =
    artifact_exists(arttag) ? tarball_folder(YAML_DATABASE[arttag]) : error("Artifact $arttag does not exist in the database, please check the website for the available artifacts!");

tarball_folder(dict::Dict) = haskey(dict, "FOLDER") ? joinpath(tarball_folder(), dict["FOLDER"]) : joinpath(tarball_folder(), dict["folder"]);


"""

    tarball_file(arttag::String)

Returns the path of the tarball file, given
- `arttag` GriddingMachine artifact tag

"""
function tarball_file(arttag::String)
    return joinpath(tarball_folder(arttag), "$arttag.tar.gz")
end;
