###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}

Hierachy of AbstractDataset
- [`MeanMonthlyLAI`](@ref)
"""
abstract type AbstractDataset{FT} end




"""
    struct MeanMonthlyLAI{FT<:AbstractFloat}

A struct that contains monthly mean LAI

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct MeanMonthlyLAI{FT<:AbstractFloat} <: AbstractDataset{FT}
    "Monthly mean LAI"
    LAI::Array{FT,3} = ncread(joinpath(artifact"lai_monthly_mean",
                                               "lai_monthly_mean.nc4"),
                              "LAI");
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(LAI)[2]
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(LAI)[1]
end
