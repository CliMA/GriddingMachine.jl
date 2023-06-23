#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    griddingmachine_dict()

Create a Dict that stores information about GriddingMachine tag

"""
function griddingmachine_dict()
    @info "These inputs are meant to generate the GriddingMachine TAG...";

    # functions to use in while loop
    _jdg_1(x) = (x != "" && !occursin(" ", x));
    _jdg_2(x) = (isnothing(x) || !occursin(" ", x));
    _jdg_3(x) = (x > 0);
    _jdg_4(x) = (x != "" && !occursin(" ", x) && x[end:end] in ["H", "D", "M", "Y"]);
    _jdg_5(x) = (isnothing(x) || x isa Vector);
    _jdg_6(x) = (x in ["N", "NO", "Y", "YES"]);
    _opr_1(x) = (x == "" ? nothing : uppercase(x));
    _opr_2(x) = parse(Int, x);
    _opr_3(x) = (
        if x == ""
            return nothing
        elseif occursin(":", x)
            _x_split = split(x, ":");
            if length(_x_split) == 2
                _min = parse(Int, _x_split[1]);
                _max = parse(Int, _x_split[2]);
                return collect(_min:_max)
            else length(_x_split) > 2
                _min = parse(Int, _x_split[1]);
                _stp = parse(Int, _x_split[2]);
                _max = parse(Int, _x_split[3]);
                return collect(_min:_stp:_max)
            end;
        elseif occursin(",", x)
            _x_split = split(x, ",");
            return [parse(Int, _str) for _str in _x_split];
        else
            return [parse(Int, x)];
        end;
    );

    # loop the inputs until satisfied
    _griddingmachine_dict = Dict{String,Any}();
    while true
        _msg = "    Please indicate the level 1 label for the dataset (e.g., GPP as in GPP_VPM_2X_1M_V1) > ";
        _label = verified_input(_msg, uppercase, _jdg_1);

        _msg = "    Please indicate the level 2 label for the dataset (e.g., VPM as in GPP_VPM_2X_1M_V1, leave empty is there is not any) > ";
        _label_extra = verified_input(_msg, _opr_1, _jdg_2);

        _msg = "    Please indicate the spatial resolution represented with an integer (N for 1/N °) > ";
        _spatial_resolution_nx = verified_input(_msg, _opr_2, _jdg_3);

        _msg = "    Please indicate the temporal resolution (e.g., 8D, 1M, and 1Y) > ";
        _temporal_resolution = verified_input(_msg, uppercase, _jdg_4);

        _msg = "    Please indicate the range of years (e.g., 2001:2022, and 2001,2005,2020 and empty for non-specific) > ";
        _years = verified_input(_msg, _opr_3, _jdg_5);

        _msg = "    Please indicate the version number of the dataset (1 for V1) > ";
        _version = verified_input(_msg, _opr_2, _jdg_3)

        _labeling = isnothing(_label_extra) ? _label : _label * "_" * _label_extra;
        if isnothing(_years)
            @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_V$(_version)";
        else
            @info "The GriddingMachine tag will be $(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_YEAR_V$(_version)";
        end;

        # ask if the TAG looks okay, if so break
        _msg = "Is the generated tag okay? If not, type <N/n or No> to redo the inputs > ";
        _try_again = (verified_input(_msg, uppercase, _jdg_6) in ["N", "NO"]);
        if !_try_again
            _griddingmachine_dict = Dict{String,Any}(
                "LABEL"         => _label,
                "EXTRA_LABEL"   => _label_extra,
                "LAT_LON_RESO"  => _spatial_resolution_nx,
                "TEMPORAL_RESO" => _temporal_resolution,
                "YEARS"         => _years,
                "VERSION"       => _version,
            );
            break;
        end;
    end;

    return _griddingmachine_dict
end


#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    griddingmachine_tag(dict::Dict, year::Int = 0)

Generate the GriddingMachine TAG, given
- `dict` Dict readed from JSON file
- `year` Which year (used only when YEARS in dict is not nothing)

"""
function griddingmachine_tag(dict::Dict, year::Int = 0)
    _griddingmachine_dict = dict["GRIDDINGMACHINE"];

    _years = _griddingmachine_dict["YEARS"];
    _label = _griddingmachine_dict["LABEL"];
    _label_extra = _griddingmachine_dict["EXTRA_LABEL"];
    _labeling = isnothing(_label_extra) ? _label : _label * "_" * _label_extra;
    _spatial_resolution_nx = _griddingmachine_dict["LAT_LON_RESO"];
    _temporal_resolution = _griddingmachine_dict["TEMPORAL_RESO"];
    _version = _griddingmachine_dict["VERSION"];

    if isnothing(_years)
        _tag = "$(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_V$(_version)";
    else
        _tag = "$(_labeling)_$(_spatial_resolution_nx)X_$(_temporal_resolution)_$(year)_V$(_version)";
    end;

    return _tag
end
