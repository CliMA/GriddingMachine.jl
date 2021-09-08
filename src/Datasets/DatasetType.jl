###############################################################################
#
# General data struct
#
###############################################################################
"""
    struct GriddedDataset{FT<:AbstractFloat}

A general struct to store data

# Fields
$(FIELDS)
"""
Base.@kwdef struct GriddedDataset{FT<:AbstractFloat}
    "Gridded dataset"
    data::Array{FT,3} = zeros(360,180,1);
    "Realistic range"
    lims::Array{FT,1} = FT[-100,100]
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(data,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(data,1)
    "Time resolution: D-M-Y-C: day-month-year-century"
    res_time::String = "1Y"
    "Variable name"
    var_name::String = "ZEROS"
    "Variable attribute"
    var_attr::Dict{String,String} = Dict("longname" => "ZEROS",
                                         "units"    => "-")
end
