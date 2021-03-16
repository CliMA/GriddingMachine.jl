###############################################################################
#
# Abstract ERA5 dataset type
#
###############################################################################
"""
    abstract type AbstractERA5Data{FT}

Hierachy of AbstractUngriddedData
- [`ERA5LandHourly`](@ref)
"""
abstract type AbstractERA5Data end








###############################################################################
#
# ERA5 data types
#
###############################################################################
"""
    struct ERA5LandHourly <: AbstractERA5Data

ERA5-Land hourly data from 1981 to present:
    https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land
"""
struct ERA5LandHourly <: AbstractERA5Data end
