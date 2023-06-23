#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    map_info_dict()

Return a dict that contains map set up information to generate a JSON file

"""
function map_info_dict()
    @info "These inputs are meant to determine what changes are required to pre-process the dataset...";

    # functions to use within while loop
    _jdg_1(x) = (x in ["GEOTIFF", "NETCDF"]);
    _jdg_2(x) = (x in ["CYLINDRICAL", "SINUSOIDAL"]);
    _jdg_3(x) = (x in [false, true]);
    _jdg_4(x) = (
        if x == "GLOBAL"
            return true
        elseif (x isa Vector) && length(x) == 4
            if !(-90 <= x[1] < x[2] <= 90)
                return false
            elseif !((-180 <= x[3] < x[4] <= 180) || (0 <= x[3] < x[4] <= 360))
                return false
            else
                return true
            end;
        else
            return false
        end;
    );
    _jdg_5(x) = (x in ["N", "NO", "Y", "YES"]);
    _opr_1(x) = (
        if uppercase(x) in ["G", "GEOTIFF", "TIFF"]
            return "GEOTIFF"
        elseif uppercase(x) in ["N", "NETCDF"]
            return "NETCDF"
        else
            return uppercase(x)
        end;
    );
    _opr_2(x) = (
        if uppercase(x) in ["C", "CYLINDRICAL"]
            return "CYLINDRICAL"
        elseif uppercase(x) in ["S", "SINUSOIDAL"]
            return "SINUSOIDAL"
        else
            return uppercase(x)
        end;
    );
    _opr_3(x) = (
        if uppercase(x) in ["C", "CENTER", "Y", "YES"]
            return true
        elseif uppercase(x) in ["E", "EDGE", "N", "NO"]
            return false
        else
            return uppercase(x)
        end;
    );
    _opr_4(x) = (
        if uppercase(x) in ["G", "GLOBAL"]
            return "GLOBAL"
        elseif occursin(",", x)
            return [parse(Float64, _str) for _str in split(x, ",")];
        else
            return uppercase(x)
        end;
    );
    _opr_5(x) = (
        if uppercase(x) in ["Y", "YES"]
            return true
        elseif uppercase(x) in ["N", "NO"]
            return false
        else
            return uppercase(x)
        end;
    );

    # loop the inputs until satisfied
    _map_info_dict = Dict{String,Any}();
    while true
        _msg = "    What is the format of the input dataset? (NetCDF or GeoTIFF) > ";
        _format = verified_input(_msg, _opr_1, _jdg_1);

        _msg = "    What is the projection of the dataset? (Cylindrical or Sinusoidal) > ";
        _projection = verified_input(_msg, _opr_2, _jdg_2);

        _msg = "    Does the value represent data in the center of a grid? (Y for Center or N for Edge) > ";
        _represent = verified_input(_msg, _opr_3, _jdg_3);

        _msg = "    What is the coverage of the dataset? (Global or not; if not global, type in the conner values in the order or min lat, max lat, min lon, max lon) > ";
        _coverages = verified_input(_msg, _opr_4, _jdg_4);

        _msg = "    Do you need to flip the latitudinal direction? (Yes or No) > ";
        _flip_lat = verified_input(_msg, _opr_5, _jdg_3);

        _msg = "    Do you need to flip the longitudinal direction? (Yes or No) > ";
        _flip_lon = verified_input(_msg, _opr_5, _jdg_3);

        _map_info_dict = Dict{String,Any}(
            "FOLDER"             => "",
            "FILE_NAME_PATTERN"  => "",
            "FILE_NAME_FUNCTION" => "",
            "FORMAT"             => _format,
            "PROJECTION"         => _projection,
            "VALUE_AT"           => _represent,
            "COVERAGE"           => _coverages,
            "FLIP_LAT"           => _flip_lat,
            "FLIP_LON"           => _flip_lon,
        )
        @show _map_info_dict

        # ask if the Dict looks okay, if so break
        _msg = "Is the generated dict okay? If not, type <N/n or No> to redo the inputs > ";
        _try_again = (verified_input(_msg, uppercase, _jdg_5) in ["N", "NO"]);
        if !_try_again
            break;
        end;
    end;

    return _map_info_dict
end
