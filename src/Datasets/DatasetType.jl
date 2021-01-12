###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}

Hierachy of AbstractDataset
- [`AbstractLeafDataset`](@ref)
- [`AbstractStandDataset`](@ref)
"""
abstract type AbstractDataset{FT} end








###############################################################################
#
# Leaf Level Datasets
#
###############################################################################
"""
    abstract type AbstractLeafDataset{FT}

Hierachy of AbstractLeafDataset
- [`LeafChlorophyll`](@ref)
- [`LeafNitrogen`](@ref)
- [`LeafPhosphorus`](@ref)
- [`LeafSLA`](@ref)
- [`VcmaxOptimalCiCa`](@ref)
"""
abstract type AbstractLeafDataset{FT} <: AbstractDataset{FT} end




"""
    struct LeafChlorophyll{FT}

<details>
<summary>
Struct for leaf chlorophyll content
[Link to Dataset Source](https://doi.org/10.1016/j.rse.2019.111479)
</summary>

```
@article{croft2020global,
    author = {Croft, H and Chen, JM and Wang, R and Mo, G and Luo, S and Luo, X
        and He, L and Gonsamo, A and Arabian, J and Zhang, Y and others},
    year = {2020},
    title = {The global distribution of leaf chlorophyll content},
    journal = {Remote Sensing of Environment},
    volume = {236},
    pages = {111479},
}
```
</details>
"""
struct LeafChlorophyll{FT}  <: AbstractLeafDataset{FT} end




"""
    struct LeafNitrogen{FT}

<details>
<summary>
Struct for leaf nitrogen content
[Link to Dataset Source](https://doi.org/10.1073/pnas.1708984114)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and
        Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee,
        Arindam and Atkin, Owen K and Kattge, Jens and Amiaud, Bernard and
        others},
    year = {2017},
    title = {Mapping local and global variability in plant trait
        distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
```
</details>
"""
struct LeafNitrogen{FT}  <: AbstractLeafDataset{FT} end




"""
    struct LeafPhosphorus{FT}
<details>
<summary>
Struct for leaf phosphorus content
[Link to Dataset Source](https://doi.org/10.1073/pnas.1708984114)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and
        Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee,
        Arindam and Atkin, Owen K and Kattge, Jens and Amiaud, Bernard and
        others},
    year = {2017},
    title = {Mapping local and global variability in plant trait
        distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
```
</details>
"""
struct LeafPhosphorus{FT}  <: AbstractLeafDataset{FT} end




"""
    struct LeafSLA{FT}

<details>
<summary>
Struct for leaf specific leaf area (inverse of leaf mass per area)
[Link to Dataset Source](https://doi.org/10.1073/pnas.1708984114)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and
        Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee,
        Arindam and Atkin, Owen K and Kattge, Jens and Amiaud, Bernard and
        others},
    year = {2017},
    title = {Mapping local and global variability in plant trait
        distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
```
</details>
"""
struct LeafSLA{FT}  <: AbstractLeafDataset{FT} end




"""
    struct VcmaxOptimalCiCa{FT}

Struct for Vcmax estimated from optimal Ci:Ca ratio
"""
struct VcmaxOptimalCiCa{FT} <: AbstractLeafDataset{FT} end








###############################################################################
#
# Stand Level Datasets
#
###############################################################################
"""
    abstract type AbstractStandDataset{FT}

Hierachy of AbstractStandDataset
- [`CanopyHeightGLAS`](@ref)
- [`ClumpingIndexMODIS`](@ref)
- [`ClumpingIndexPFT`](@ref)
- [`GPPMPIv006`](@ref)
- [`GPPVPMv20`](@ref)
- [`LAIMonthlyMean`](@ref)
- [`NPPModis`](@ref)
- [`TreeDensity`](@ref)
"""
abstract type AbstractStandDataset{FT} <: AbstractDataset{FT} end




"""
    struct CanopyHeightGLAS{FT}

<details>
<summary>
Struct for canopy height from GLAS ICESat
[Link to Dataset Source](https://doi.org/10.1029/2011JG001708)
</summary>

```
@article{simard2011mapping,
    author = {Simard, Marc and Pinto, Naiara and Fisher, Joshua B and Baccini,
        Alessandro},
    year = {2011},
    title = {Mapping forest canopy height globally with spaceborne lidar},
    journal = {Journal of Geophysical Research: Biogeosciences},
    volume = {116},
    number = {G4021}
}
```
</details>
"""
struct CanopyHeightGLAS{FT} <: AbstractStandDataset{FT} end




"""
    struct ClumpingIndexMODIS{FT}

Struct for canopy height from GLAS ICESat
"""
struct ClumpingIndexMODIS{FT} <: AbstractStandDataset{FT} end




"""
    struct ClumpingIndexPFT{FT}

Struct for canopy height from GLAS ICESat, for different plant functional
    types. The indices are Broadleaf, Needleleaf, C3 grasses, C4 grasses,
    and shrubland
"""
struct ClumpingIndexPFT{FT} <: AbstractStandDataset{FT} end




"""
    struct GPPMPIv006{FT}

Struct for MPI GPP v006
"""
struct GPPMPIv006{FT} <: AbstractStandDataset{FT} end




"""
    struct GPPVPMv20{FT}

Struct for VPM GPP v20
"""
struct GPPVPMv20{FT}  <: AbstractStandDataset{FT} end




"""
    struct LAIMonthlyMean{FT}

<details>
<summary>
Struct for monthly mean MODIS LAI
[Link to Dataset Source](https://doi.org/10.3334/ORNLDAAC/1653)
</summary>

```
@article{mao2019global,
    author = {Mao, J and Yan, B},
    year = {2019},
    title = {Global monthly mean leaf area index climatology, 1981-2015},
    journal = {ORNL DAAC}
}
```
</details>
"""
struct LAIMonthlyMean{FT}  <: AbstractStandDataset{FT} end




"""
    struct NPPModis{FT}

Struct for Modis NPP
"""
struct NPPModis{FT} <: AbstractStandDataset{FT} end




"""
    struct SIFTropomi740{FT}

Struct for TROPOMI SIF @ 740 nm
"""
struct SIFTropomi740{FT} <: AbstractStandDataset{FT} end




"""
    struct TreeDensity{FT}

Struct for tree density (number of trees per km⁻²)
"""
struct TreeDensity{FT} <: AbstractStandDataset{FT} end








###############################################################################
#
# Surface level land mark
#
###############################################################################
"""
    abstract type AbstractSurfaceDataset{FT}

Hierachy of AbstractSurfaceDataset
- [`LandMaskERA5`](@ref)
"""
abstract type AbstractSurfaceDataset{FT} <: AbstractDataset{FT} end




"""
    struct FloodPlainHeight{FT}

Flood plain height
"""
struct FloodPlainHeight{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct LandElevation{FT}

Land elevation (height above mean sea level)
"""
struct LandElevation{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct LandMaskERA5{FT}

Struct for land mask from ERA5
"""
struct LandMaskERA5{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct RiverHeight{FT}

River height
"""
struct RiverHeight{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct RiverLength{FT}

River length
"""
struct RiverLength{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct RiverManning{FT}

River manning coefficient
"""
struct RiverManning{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct RiverWidth{FT}

River width
"""
struct RiverWidth{FT}  <: AbstractSurfaceDataset{FT} end




"""
    struct UnitCatchmentArea{FT}

Unit catchment area
"""
struct UnitCatchmentArea{FT}  <: AbstractSurfaceDataset{FT} end








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
    "Gridded dataset"
    data::Array{FT,3} = FT.(ncread(joinpath(artifact"NPP_MODIS_1X_1Y",
                                           "npp_modis_1X_1Y_2000.nc"),
                                   "npp"));
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(data,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(data,1)
    "Time resolution: D-M-Y-C: day-month-year-century"
    res_time::String = "8D"
    "Variable name"
    var_name::String = "NPP"
    "Variable attribute"
    var_attr::Dict{String,String} = Dict("longname" => "NPP",
                                         "units"    => "kg C m⁻² s⁻¹")
    "Type label"
    dt::AbstractDataset = NPPModis{FT}()
end
