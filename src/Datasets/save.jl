###############################################################################
#
# Save the dataset
#
###############################################################################
"""
    save_LUT!(ds::GriddedDataset{FT},
              filename::String) where {FT<:AbstractFloat}
    save_LUT!(data::Array{FT,2},
              filename::String) where {FT<:AbstractFloat}
    save_LUT!(data::Array{FT,3},
              filename::String,
              var_name::String,
              var_attr::Dict{String,String}) where {FT<:AbstractFloat}

Save the dataset, given
- `ds` [`GriddedDataset`](@ref) type struct
- `filename` NC file name to save to
- `data` Temporaty data
- `var_name` Variable name in nc file
- `var_attr` Variable attributes in nc file

Note that `save_LUT!(data, filename)` is designed to use with temporaty data
    only, be cautious when using this function.
"""
function save_LUT!(
            ds::GriddedDataset{FT},
            filename::String
) where {FT<:AbstractFloat}
    save_LUT!(ds.data, filename, ds.var_name, ds.var_attr);

    return nothing
end




function save_LUT!(
            data::Array{FT,2},
            filename::String
) where {FT<:AbstractFloat}
    # attributes
    varatts = Dict("longname" => "Variable" , "units" => "-");

    # create nc file
    save_nc!(filename, "Var", varatts, data);

    return nothing
end




function save_LUT!(
            data::Array{FT,3},
            filename::String,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    save_nc!(filename, var_name, var_attr, data);

    return nothing
end
