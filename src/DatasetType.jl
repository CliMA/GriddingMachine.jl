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
    mutable struct MeanMonthlyLAI{FT<:AbstractFloat}

A struct that contains monthly mean LAI

# Fields
$(DocStringExtensions.FIELDS)
"""
mutable struct MeanMonthlyLAI{FT<:AbstractFloat} <: AbstractDataset{FT}
    "Latitude resolution `[°]`"
    res_lat::FT
    "Longitude resolution `[°]`"
    res_lon::FT
    "Monthly mean LAI"
    LAI::Array{FT,3}
end
