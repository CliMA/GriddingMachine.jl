#######################################################################################################################################################################################################
#
# Changes to the functions
# General
#     2024-Oct-28: add functions to determine if the artifact exists
#
#######################################################################################################################################################################################################
"""

    artifact_exists(artstr::String)

Returns true if the artifact exists in the database, given
- `artstr` GriddingMachine artifact tag or SHA

"""
function artifact_exists(artstr::String)
    return artifact_sha_exist(artstr) || artifact_tag_exist(artstr)
end;

artifact_sha_exist(arthash::String) = arthash in YAML_SHAS;
artifact_tag_exist(arttag::String) = arttag in YAML_TAGS;


"""

    artifact_downloaded(arttag::String)

Returns true if the artifact is downloaded, given
- `arttag` GriddingMachine artifact tag

"""
function artifact_downloaded(arttag::String)
    return isfile(artifact_file(arttag))
end;
