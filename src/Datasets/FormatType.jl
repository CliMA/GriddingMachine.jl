###############################################################################
#
# Abstract format type
#
###############################################################################
"""
    abstract type AbstractFormat

Hierachy of AbstractFormat
- [`FormatTIFF`](@ref)
- [`FormatNC`](@ref)
"""
abstract type AbstractFormat end




"""
    struct FormatTIFF
"""
struct FormatTIFF <: AbstractFormat end




"""
    struct FormatNC
"""
struct FormatNC <: AbstractFormat end
