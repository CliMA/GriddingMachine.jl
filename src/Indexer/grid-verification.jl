"""

    verify_dict!(gm_dict::Dict{String,Any})

Verify the dictionary per key and value to make sure there is not NaN, given
- `dict` GriddingMachine data or weather driver dictionary

"""
function verify_dict!(dict::Dict{String,Any})
    # verify the GriddingMachine data dictionary per key and value to make sure there is not NaN
    for (key, value) in dict
        if typeof(value) <: Number
            if isnan(value)
                return error("Key $key is NaN!");
            end;
        elseif typeof(value) <: AbstractArray
            if any(isnan.(value))
                return error("Key $key contains NaN!");
            end;
        end;
    end;

    return nothing
end;
