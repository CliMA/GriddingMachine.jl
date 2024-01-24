#=
#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#     2023-May-17: done deploy function
#
#######################################################################################################################################################################################################
"""

    deploy_griddingmachine_artifacts!(dict::Dict)

Deploy GriddingMachine artifacts, given
- `dict` A dictionary based on JSON file

"""
function deploy_griddingmachine_artifacts! end;

deploy_griddingmachine_artifacts!(dict::Dict, art_toml::String, rep_locf::String, art_tarf::String; art_urls::Vector{String} = FTP_URLS) = (
    _dict_grid = dict["GRIDDINGMACHINE"];

    # determine if there is any information for years
    _years = _dict_grid["YEARS"];
    _i_years = (isnothing(_years) ? [1] : eachindex(_years));
    for _i_year in _i_years
        _tag = (isnothing(_years) ? griddingmachine_tag(dict, 0) : griddingmachine_tag(dict, _years[_i_year]));
        _artifact_files = ["$(_tag).nc"];
        deploy_artifact!(art_toml, _tag, rep_locf, _artifact_files, art_tarf, art_urls);
    end;

    return nothing
)

deploy_griddingmachine_artifacts!(dict::Dict) = (
    _dict_grid = dict["GRIDDINGMACHINE"];

    # determine if there is any information for years
    _years = _dict_grid["YEARS"];
    _i_years = (isnothing(_years) ? [1] : eachindex(_years));
    for _i_year in _i_years
        _tag = (isnothing(_years) ? griddingmachine_tag(dict, 0) : griddingmachine_tag(dict, _years[_i_year]));
        _artifact_files = ["$(_tag).nc"];
        deploy_artifact!(ARTIFACT_TOML, _tag, DATASET_FOLDER, _artifact_files, ARTIFACT_FOLDER, FTP_URLS);
    end;

    return nothing
)
=#
