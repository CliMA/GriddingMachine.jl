###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}

Hierachy of AbstractDataset
- [`MeanMonthlyLAI`](@ref)
- [`VPMGPPv20`](@ref)
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
    LAI::Array{FT,3} = FT.(ncread(joinpath(artifact"example",
                                           "lai_example.nc"),
                                  "LAI"));
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(LAI,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(LAI,1)
end




"""
    struct VPMGPPv20{FT<:AbstractFloat}

A struct that contains monthly mean LAI, default at year 2000

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct VPMGPPv20{FT<:AbstractFloat} <: AbstractDataset{FT}
    "Monthly mean LAI"
    GPP::Array{FT,3} = FT.(ncread(joinpath(artifact"example",
                                           "gpp_example.nc"),
                                  "GPP"));
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(GPP,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(GPP,1)
    "Time resolution `[day]`"
    res_day::Int = 8
end
