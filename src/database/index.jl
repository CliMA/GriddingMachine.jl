#######################################################################################################################################################################################################
#
# Changes to the functions
# General
#     2024-Oct-28: add functions to get the path or folder of the artifact
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

    tarball_folder(dict::Dict)

Returns the path of the tarball folder, given
- `dict` A dictionary of the artifact

"""
function tarball_folder(dict::Dict)
    return joinpath(GRIDDINGMACHINE_HOME, "tarballs", dict["folder"])
end;
