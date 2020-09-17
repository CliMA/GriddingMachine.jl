###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}

Hierachy of AbstractDataset
- [`AbstractCanopyHeight`](@ref)
- [`AbstractClumpingIndex`](@ref)
- [`AbstractGPP`](@ref)
- [`AbstractLAI`](@ref)
- [`AbstractLeafMN`](@ref)
- [`AbstractVcmax`](@ref)
"""
abstract type AbstractDataset{FT} end








###############################################################################
#
# Canopy Height
#
###############################################################################
"""
abstract type AbstractCanopyHeight{FT}

Hierachy of AbstractCanopyHeight
- [`CanopyHeightGLAS`](@ref)
"""
abstract type AbstractCanopyHeight{FT} <: AbstractDataset{FT} end




"""
    struct GPPMPIv006{FT}

Struct for canopy height from GLAS ICESat
"""
struct CanopyHeightGLAS{FT} <: AbstractCanopyHeight{FT} end








###############################################################################
#
# Clumping index
#
###############################################################################
"""
abstract type AbstractCanopyHeight{FT}

Hierachy of AbstractCanopyHeight
- [`ClumpingIndexMODIS`](@ref)
- [`ClumpingIndexPFT`](@ref)
"""
abstract type AbstractClumpingIndex{FT} <: AbstractDataset{FT} end




"""
    struct GPPMPIv006{FT}

Struct for canopy height from GLAS ICESat
"""
struct ClumpingIndexMODIS{FT} <: AbstractClumpingIndex{FT} end




"""
    struct GPPMPIv006{FT}

Struct for canopy height from GLAS ICESat, for different plant functional
    types. The indices are Broadleaf, Needleleaf, C3 grasses, C4 grasses,
    and shrubland
"""
struct ClumpingIndexPFT{FT} <: AbstractClumpingIndex{FT} end








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
# Leaf properties
#
###############################################################################
"""
    abstract type AbstractLeafMN{FT}

Hierachy of AbstractLAI
- [`LeafNitrogen`](@ref)
- [`LeafPhosphorus`](@ref)
- [`LeafSLA`](@ref)
"""
abstract type AbstractLeafMN{FT} <: AbstractDataset{FT} end




"""
    struct LeafNitrogen{FT}

Struct for leaf nitrogen content
"""
struct LeafNitrogen{FT}  <: AbstractLeafMN{FT} end




"""
    struct LeafPhosphorus{FT}

Struct for leaf specific leaf area (inverse of leaf mass per area)
"""
struct LeafPhosphorus{FT}  <: AbstractLeafMN{FT} end




"""
    struct LeafSLA{FT}

Struct for leaf specific leaf area (inverse of leaf mass per area)
"""
struct LeafSLA{FT}  <: AbstractLeafMN{FT} end








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
    res_time::String = "8D"
    "Type label"
    dt::AbstractDataset = AbstractGPP{FT}()
end
