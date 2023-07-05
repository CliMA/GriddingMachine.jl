#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    variable_dict(_has_std)

Return a dict of the input variable setup
- `_has_std` Whether the data has error/standard deviation to be included

"""
function variable_dict(_has_std::Bool)
    # functions to use in while loop
    _jdg_1(x) = (x != "");
    _jdg_2(x) = (
        try
            parse(Int, x)
            return true
        catch e
            return false
        end;
    );
    _jdg_3(x) = (x in ["N", "NO", "Y", "YES"]);

    info = ["data", "error"];

    # loop the inputs until satisfied
    _data_dict = Dict{String,Any}();
    _std_dict = Dict{String,Any}();
    
    for type in info

        if (type == "error" && !_has_std) continue end;
        
        while true
            _msg = "        Please input $(type) label or band name > ";
            _name = verified_input(_msg, _jdg_1);

            _msg = "        What is the longitude axis number of the $(type)? (e.g., 1 for [lon,lat,time] and 2 for [lat,lon,time]) > ";
            _i_lon = parse(Int, verified_input(_msg, _jdg_2));

            _msg = "        What is the latitude axis number of the $(type)? (e.g., 2 for [lon,lat,time] and 1 for [lat,lon,time]) > ";
            _i_lat = parse(Int, verified_input(_msg, _jdg_2));

            _msg = "        What is the index axis number of the $(type)? (e.g., 3 for time in [lon,lat,time] and 0 for [lat,lon]) > "
            _i_ind = parse(Int, verified_input(_msg, _jdg_2));
            if _i_ind == 0
                _i_ind = nothing;
            end;

            _msg = "        What is your mask function for NaN, type it here, e.g., x -> (0.1 < x <= 0.2 && x * 6 > 1 ? NaN : x) > ";
            print(_msg);
            _masking_function = readline();

            _msg = "        If you have extra scaling you want to make, type it here (NCDatasets may do that already, double check, example: x -> log(x)) > ";
            print(_msg);
            _scaling_function = readline();

            _temp_dict = Dict{String,Any}(
                "DATA_NAME"            => _name,
                "LONGITUDE_AXIS_INDEX" => _i_lon,
                "LATITUDE_AXIS_INDEX"  => _i_lat,
                "INDEX_AXIS_INDEX"     => _i_ind,
                "SCALING_FUNCTION"     => _scaling_function,
                "MASKING_FUNCTION"     => _masking_function,
            );
            @show _temp_dict;

            if (type == "data")
                _data_dict = _temp_dict;
            else
                _std_dict = _temp_dict;
            end;

            # ask if the Dict looks okay, if so break
            _msg = "Is the generated dict okay? If not, type <N/n or No> to redo the inputs > ";
            _try_again = (verified_input(_msg, uppercase, _jdg_3) in ["N", "NO"]);
            if !_try_again
                break;
            end;
        end;
        
    end;

    return _data_dict, _std_dict;
end


#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    variable_dicts()

Create a vector of Dicts that store variable information

"""
function variable_dicts()
    # functions to use in while loop
    _jdg_1(x) = (
        try
            parse(Int, x)
            return true
        catch e
            return false
        end;
    );
    _jdg_3(x) = (x in ["N", "NO", "Y", "YES"]);

    @info "These questions are about how to read the data, please be careful about them...";

    # ask for how many independent variables do you want to save as DATA
    _msg = "    How many variables do you want to save as DATA (e.g., combine data1 and data2 in one netcdf file) > ";
    _data_count = parse(Int, verified_input(_msg, _jdg_1));
    _data_dicts = Dict{String,Any}[];
    
    _msg = "    Do you have error/standard deviation to input for the variables? > ";
    _has_std = (verified_input(_msg, uppercase, _jdg_3) in ["Y", "YES"]);
    _std_dicts = Dict{String,Any}[];

    for _i_data in 1:_data_count
        println("    For data $(_i_data):");
        v_d = variable_dict(_has_std);
        push!(_data_dicts, v_d[1]);
        if _has_std push!(_std_dicts, v_d[2]) end;
        println();
    end;

    return _data_dicts, _std_dicts
end
