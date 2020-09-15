###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}

Hierachy of AbstractDataset
- [`AbstractGPP`](@ref)
- [`AbstractLAI`](@ref)
"""
abstract type AbstractDataset{FT} end








###############################################################################
#
# GPP
#
###############################################################################
"""
    abstract type AbstractGPP{FT}

Hierachy of AbstractGPP
- [`GPPMPIv006`](@ref)
- [`GPPVPMv20`](@ref)
"""
abstract type AbstractGPP{FT} <: AbstractDataset{FT} end




"""
    struct GPPMPIv006{FT}

Struct for MPI GPP v006
"""
struct GPPMPIv006{FT} <: AbstractGPP{FT} end




"""
    struct GPPVPMv20{FT}

Struct for VPM GPP v20
"""
struct GPPVPMv20{FT}  <: AbstractGPP{FT} end








###############################################################################
#
# LAI
#
###############################################################################
"""
    abstract type AbstractLAI{FT}

Hierachy of AbstractLAI
- [`LAIMonthlyMean`](@ref)
"""
abstract type AbstractLAI{FT} <: AbstractDataset{FT} end




"""
    struct LAIMonthlyMean{FT}

Struct for monthly mean MODIS LAI
"""
struct LAIMonthlyMean{FT}  <: AbstractLAI{FT} end








###############################################################################
#
# Vcmax
#
###############################################################################
"""
    abstract type AbstractLAI{FT}

Hierachy of AbstractVcmax
- [`VcmaxOptimalCiCa`](@ref)
"""
abstract type AbstractVcmax{FT} <: AbstractDataset{FT} end




"""
    struct VcmaxOptimalCiCa{FT}

Struct for Vcmax estimated from optimal Ci:Ca ratio
"""
struct VcmaxOptimalCiCa{FT} <: AbstractVcmax{FT} end








###############################################################################
#
# General data struct
#
###############################################################################
"""
    struct GriddedDataset{FT<:AbstractFloat}

A general struct to store data

# Fields
$(DocStringExtensions.FIELDS)
"""
Base.@kwdef struct GriddedDataset{FT<:AbstractFloat}
    "Monthly mean LAI"
    data::Array{FT,3} = FT.(ncread(joinpath(artifact"example",
                                           "gpp_example.nc"),
                                  "GPP"));
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(data,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(data,1)
    "Time resolution: D-M-Y-C: day-month-year-century"
    resolution::String = "8D"
    "Type label"
    data_type::AbstractDataset = AbstractGPP{FT}()
end
