#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    reference_attribute_dict()

Create a Dict that stores reference information about variable attributes

"""
function reference_attribute_dict()
    @info "These inputs are meant to generate the reference attributes witin the Netcdf dataset...";

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

    # loop the inputs until satisfied
    _attribute_dict = Dict{String,Any}();
    while true
        _msg = "    Please input the author information (e.g., Name S. et al.) > ";
        _authors = verified_input(_msg, _jdg_1);

        _msg = "    Please input the year of the publication > ";
        _year_pub = verified_input(_msg, _jdg_2);

        _msg = "    Please input the title of the publication > ";
        _title = verified_input(_msg, _jdg_1);

        _msg = "    Please input the journal of the publication > ";
        _journal = verified_input(_msg, _jdg_1);

        _msg = "    Please input the DOI of the publication > ";
        _doi = verified_input(_msg, _jdg_1);

        _attribute_dict = Dict{String,String}(
            "authors"   => _authors,
            "year"      => _year_pub,
            "title"     => _title,
            "journal"   => _journal,
            "doi"       => _doi,
        );
        @show _attribute_dict

        # ask if the Dict looks okay, if so break
        _msg = "Is the generated dict okay? If not, type <N/n or No> to redo the inputs > ";
        _try_again = (verified_input(_msg, uppercase, _jdg_3) in ["N", "NO"]);
        if !_try_again
            break;
        end;
    end;

    return _attribute_dict
end


#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    variable_attribute_dict()

Create a Dict that stores information about variable attributes

"""
function variable_attribute_dict()
    @info "These inputs are meant to generate the variable attributes witin the Netcdf dataset...";

    # functions to use in while loop
    _jdg_1(x) = (x != "");
    _jdg_2(x) = (x in ["N", "NO", "Y", "YES"]);

    # loop the inputs until satisfied
    _attribute_dict = Dict{String,Any}();
    while true
        _msg = "    Please input the long name of the variable to save > ";
        _longname = verified_input(_msg, _jdg_1);

        _msg = "    Please input the unit of the variable to save > ";
        _unit = verified_input(_msg, _jdg_1);

        _msg = "    Please input some more details of the variable to save > ";
        _about = verified_input(_msg, _jdg_1);

        _attribute_dict = Dict{String,String}(
            "long_name" => _longname,
            "unit"      => _unit,
            "about"     => _about,
        );
        @show _attribute_dict

        # ask if the Dict looks okay, if so break
        _msg = "Is the generated dict okay? If not, type <N/n or No> to redo the inputs > ";
        _try_again = (verified_input(_msg, uppercase, _jdg_2) in ["N", "NO"]);
        if !_try_again
            break;
        end;
    end;

    return _attribute_dict
end
