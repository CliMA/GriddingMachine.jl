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

<details>
<summary>
Struct for Vcmax estimated from optimal Ci:Ca ratio
[Link to Dataset Source](https://doi.org/10.1111/ele.13210)
</summary>

```
@article{smith2019global,
    author = {Smith, Nicholas G. and Keenan, Trevor F. and Prentice, I. Colin
        and Wang, Han and Wright, Ian J. and Niinemets, Ülo and Crous, Kristine
        Y. and Domingues, Tomas F. and Guerrieri, Rossella and {Yoko Ishida},
        F. and Zhou, Shuangxi},
    year = {2019},
    title = {Global photosynthetic capacity is optimized to the environment},
    journal = {Ecology Letters},
    volume = {22},
    number = {3},
    pages = {506–517}
}
```
</details>
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

<details>
<summary>
Global clumping index data from MODIS BRDF 2006
[Link to Dataset Source](https://doi.org/10.3334/ORNLDAAC/1531)
</summary>

```
@article{he2012global,
    author={He, Liming and Chen, Jing M and Pisek, Jan and Schaaf, Crystal B
        and Strahler, Alan H},
    year={2012},
    title={Global clumping index map derived from the MODIS BRDF product},
    journal={Remote Sensing of Environment},
    volume={119},
    pages={118--130}
}
```
</details>
"""
struct ClumpingIndexMODIS{FT} <: AbstractStandDataset{FT} end




"""
    struct ClumpingIndexPFT{FT}

<details>
<summary>
Struct for canopy height from GLAS ICESat, for different plant functional
    types. The indices are Broadleaf, Needleleaf, C3 grasses, C4 grasses, and
    shrubland. Data from Global clumping index data from MODIS BRDF 2006.
[Link to Dataset Source](https://doi.org/10.3334/ORNLDAAC/1531)
</summary>

```
@article{braghiere2019underestimation,
    author = {Braghiere, R{\\'e}nato Kerches and Quaife, T and Black, E and He,
        L and Chen, JM},
    year = {2019},
    title = {Underestimation of global photosynthesis in Earth System Models
        due to representation of vegetation structure},
    journal = {Global Biogeochemical Cycles},
    volume = {33},
    number = {11},
    pages = {1358--1369}
}
```
</details>
"""
struct ClumpingIndexPFT{FT} <: AbstractStandDataset{FT} end




"""
    struct GPPMPIv006{FT}

<details>
<summary>
Struct for MPI GPP v006
[Link to Dataset Source](https://doi.org/10.5194/bg-17-1343-2020)
</summary>

```
@article{jung2020scaling,
    author = {Jung, Martin and Schwalm, Christopher and Migliavacca, Mirco and
        Walther, Sophia and Camps-Valls, Gustau and Koirala, Sujan and Anthoni,
        Peter and Besnard, Simon and Bodesheim, Paul and Carvalhais, Nuno and
        others},
    year = {2020},
    title = {Scaling carbon fluxes from eddy covariance sites to globe:
        {S}ynthesis and evaluation of the {FLUXCOM} approach},
    journal = {Biogeosciences},
    volume = {17},
    number = {5},
    pages = {1343--1365}
}
```
</details>
"""
struct GPPMPIv006{FT} <: AbstractStandDataset{FT} end




"""
    struct GPPVPMv20{FT}

<details>
<summary>
Struct for VPM GPP v20
[Link to Dataset Source](https://doi.org/10.1038/sdata.2017.165)
</summary>

```
@article{zhang2017global,
    author = {Zhang, Yao and Xiao, Xiangming and Wu, Xiaocui and Zhou, Sha and
        Zhang, Geli and Qin, Yuanwei and Dong, Jinwei},
    year = {2017},
    title = {A global moderate resolution dataset of gross primary production
        of vegetation for 2000--2016},
    journal = {Scientific data},
    volume = {4},
    pages = {170165}
}
```
</details>
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

<details>
<summary>
Struct for TROPOMI SIF @ 740 nm
[Link to Dataset Source](https://doi.org/10.1029/2018GL079031)
</summary>

```
@article{kohler2018global,
    author = {K{\\"o}hler, Philipp and Frankenberg, Christian and Magney, Troy
        S and Guanter, Luis and Joiner, Joanna and Landgraf, Jochen},
    year = {2018},
    title = {Global retrievals of solar-induced chlorophyll fluorescence with
        {TROPOMI}: {F}irst results and intersensor comparison to {OCO-2}},
    journal = {Geophysical Research Letters},
    volume = {45},
    number = {19},
    pages = {10,456--10,463}
}
```
</details>
"""
struct SIFTropomi740{FT} <: AbstractStandDataset{FT} end




"""
    struct TreeDensity{FT}

<details>
<summary>
Struct for tree density (number of trees per km⁻²)
[Link to Dataset Source](https://doi.org/10.1038/nature14967)
</summary>

```
@article{crowther2015mapping,
    author = {Crowther, Thomas W and Glick, Henry B and Covey, Kristofer R and
        Bettigole, Charlie and Maynard, Daniel S and Thomas, Stephen M and
        Smith, Jeffrey R and Hintler, Gregor and Duguid, Marlyse C and
        Amatulli, Giuseppe and others},
    year = {2015},
    title = {Mapping tree density at a global scale},
    journal = {Nature},
    volume = {525},
    number = {7568},
    pages = {201--205}
}
```
</details>
"""
struct TreeDensity{FT} <: AbstractStandDataset{FT} end




"""
    struct WoodDensity{FT}

<details>
<summary>
Struct for wood density (g cm⁻³)
[Link to Dataset Source](https://doi.org/10.1111/geb.13086)
</summary>

```
@article{boonman2020assessing,
    author = {Boonman, Coline CF and Ben{\\'i}tez-L{\\'o}pez, Ana and Schipper,
        Aafke M and Thuiller, Wilfried and Anand, Madhur and Cerabolini, Bruno
        EL and Cornelissen, Johannes HC and Gonzalez-Melo, Andres and Hattingh,
        Wesley N and Higuchi, Pedro and others},
    year = {2020},
    title = {Assessing the reliability of predicted plant trait distributions
        at the global scale},
    journal = {Global Ecology and Biogeography},
    volume = {29},
    number = {6},
    pages = {1034--1051}
}
```
</details>
"""
struct WoodDensity{FT} <: AbstractStandDataset{FT} end








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
