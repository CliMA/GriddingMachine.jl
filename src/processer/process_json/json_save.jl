#=
#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#
#######################################################################################################################################################################################################
"""

    griddingmachine_json!(filename::String = "test.json")

Create a JSON file to generate GriddingMachine dataset, given
- `filename` File name of the json file to save

"""
function griddingmachine_json!(filename::String = "test.json")
    # create a dict to save as JSON file
    g_d = griddingmachine_dict();
    m_i_d = map_info_dict();
    v_d = variable_dicts();
    r_a_d = reference_attribute_dict();
    v_a_d = variable_attribute_dict();

    _json_dict = Dict{String,Any}(
        "GRIDDINGMACHINE" => g_d,
        "INPUT_MAP_SETS"  => m_i_d,
        "INPUT_VAR_SETS"  => v_d[1],
        "INPUT_STD_SETS"  => v_d[2],
        "OUTPUT_REF_ATTR" => r_a_d,
        "OUTPUT_VAR_ATTR" => v_a_d
    );

    if (length(v_d[2]) == 0)
        delete!(_json_dict, "INPUT_STD_SETS")
    end;

    # save the JSON file
    _filename = filename[end-4:end] == ".json" ? filename : "$(filename).json";
    open(_filename, "w") do f
        JSON.print(f, _json_dict, 4);
    end;

    return nothing
end
=#
