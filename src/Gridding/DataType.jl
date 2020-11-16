###############################################################################
#
# Abstract original data type
#
###############################################################################
"""
    abstract type AbstractUngriddedData{FT}

Hierachy of AbstractUngriddedData
- [`AbstractMODIS500m`](@ref)
- [`AbstractMODIS1km`](@ref)
"""
abstract type AbstractUngriddedData{FT} end








###############################################################################
#
# MODIS raw data at 500 m resolution
#
###############################################################################
"""
    abstract type AbstractMODIS500m{FT}

Hierachy of AbstractMODIS500m
- [`MOD15A2Hv006LAI`](@ref)
"""
abstract type AbstractMODIS500m{FT} <: AbstractUngriddedData{FT} end








"""
    struct MODISLeafAreaIndex

Leaf area index
"""
struct MOD15A2Hv006LAI{FT} <: AbstractMODIS500m{FT} end








###############################################################################
#
# MODIS raw data at 1 km resolution
#
###############################################################################
"""
    abstract type AbstractMODIS1km{FT}

Hierachy of AbstractMODIS1km
"""
abstract type AbstractMODIS1km{FT} <: AbstractUngriddedData{FT} end
