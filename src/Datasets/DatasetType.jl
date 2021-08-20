###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}
"""
abstract type AbstractDataset{FT} end








###############################################################################
#
# Leaf Level Datasets
#
###############################################################################
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
struct LeafChlorophyll{FT} <: AbstractDataset{FT} end




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
struct LeafPhosphorus{FT} <: AbstractDataset{FT} end








###############################################################################
#
# Stand Level Datasets
#
###############################################################################
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
struct GPPMPIv006{FT} <: AbstractDataset{FT} end




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
struct GPPVPMv20{FT} <: AbstractDataset{FT} end




"""
    struct LAIMODISv006{FT}

<details>
<summary>
Struct for MODIS LAI v006
[Link to Dataset Source](https://doi.org/10.1016/j.rse.2011.01.001)
</summary>

```
@article{yuan2011reprocessing,
	author = {Yuan, Hua and Dai, Yongjiu and Xiao, Zhiqiang and Ji, Duoying and
        Shangguan, Wei},
	year = {2011},
	title = {Reprocessing the MODIS Leaf Area Index products for land surface
        and climate modelling},
	journal = {Remote Sensing of Environment},
	volume = {115},
	number = {5},
	pages = {1171--1187}
}
```
</details>
"""
struct LAIMODISv006{FT} <: AbstractDataset{FT} end




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
struct LAIMonthlyMean{FT} <: AbstractDataset{FT} end




"""
    struct NDVIAvhrr{FT}

Struct for AVHRR NDVI
"""
struct NDVIAvhrr{FT} <: AbstractDataset{FT} end




"""
    struct NDVIAvhrr{FT}

Struct for AVHRR NIRv
"""
struct NIRvAvhrr{FT} <: AbstractDataset{FT} end




"""
    struct NDVIAvhrr{FT}

Struct for AVHRR NIRv with offset
"""
struct NIRoAvhrr{FT} <: AbstractDataset{FT} end




"""
    struct NPPModis{FT}

Struct for Modis NPP
"""
struct NPPModis{FT} <: AbstractDataset{FT} end




"""
    struct PFTPercentCLM{FT}

<details>
<summary>
Struct for Plant Function Type Fractions from CLM
[Link to Dataset Source](https://doi.org/10.1038/nature14967)
</summary>

```
@article{lawrence2007representing,
	author = {Lawrence, Peter J and Chase, Thomas N},
	year = {2007},
	title = {Representing a new MODIS consistent land surface in the Community
        Land Model (CLM 3.0)},
	journal = {Journal of Geophysical Research: Biogeosciences},
	volume = {112},
	pages = {G01023}
}
```
</details>
"""
struct PFTPercentCLM{FT} <: AbstractDataset{FT} end




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
struct SIFTropomi740{FT} <: AbstractDataset{FT} end




"""
    struct SIFTropomi740DC{FT}

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
struct SIFTropomi740DC{FT} <: AbstractDataset{FT} end




"""
    struct SoilColor{FT}

<details>
<summary>
Struct for soil color
[Link to Dataset Source](https://doi.org/10.1038/nature14967)
</summary>

```
@article{lawrence2007representing,
	author = {Lawrence, Peter J and Chase, Thomas N},
	year = {2007},
	title = {Representing a new MODIS consistent land surface in the Community
        Land Model (CLM 3.0)},
	journal = {Journal of Geophysical Research: Biogeosciences},
	volume = {112},
	pages = {G01023}
}
```
</details>
"""
struct SoilColor{FT} <: AbstractDataset{FT} end




"""
    struct VGMAlphaJules{FT}

<details>
<summary>
Struct for van Genuchten model α
[Link to Dataset Source](https://doi.org/10.1029/2019MS001784)
</summary>

```
@article{dai2019global,
    author = {Dai, Yongjiu and Xin, Qinchuan and Wei, Nan and Zhang, Yonggen
        and Shangguan, Wei and Yuan, Hua and Zhang, Shupeng and Liu, Shaofeng
        and Lu, Xingjie},
	year = {2019},
    title = {A global high-resolution data set of soil hydraulic and thermal
        properties for land surface modeling},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {11},
	number = {9},
	pages = {2996--3023}
}


```
</details>
"""
struct VGMAlphaJules{FT} <: AbstractDataset{FT} end




"""
    struct VGMLogNJules{FT}

<details>
<summary>
Struct for van Genuchten model log(n)
[Link to Dataset Source](https://doi.org/10.1029/2019MS001784)
</summary>

```
@article{dai2019global,
    author = {Dai, Yongjiu and Xin, Qinchuan and Wei, Nan and Zhang, Yonggen
        and Shangguan, Wei and Yuan, Hua and Zhang, Shupeng and Liu, Shaofeng
        and Lu, Xingjie},
	year = {2019},
    title = {A global high-resolution data set of soil hydraulic and thermal
        properties for land surface modeling},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {11},
	number = {9},
	pages = {2996--3023}
}


```
</details>
"""
struct VGMLogNJules{FT} <: AbstractDataset{FT} end




"""
    struct VGMThetaRJules{FT}

<details>
<summary>
Struct for van Genuchten model Θr
[Link to Dataset Source](https://doi.org/10.1029/2019MS001784)
</summary>

```
@article{dai2019global,
    author = {Dai, Yongjiu and Xin, Qinchuan and Wei, Nan and Zhang, Yonggen
        and Shangguan, Wei and Yuan, Hua and Zhang, Shupeng and Liu, Shaofeng
        and Lu, Xingjie},
	year = {2019},
    title = {A global high-resolution data set of soil hydraulic and thermal
        properties for land surface modeling},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {11},
	number = {9},
	pages = {2996--3023}
}


```
</details>
"""
struct VGMThetaRJules{FT} <: AbstractDataset{FT} end




"""
    struct VGMThetaSJules{FT}

<details>
<summary>
Struct for van Genuchten model Θs
[Link to Dataset Source](https://doi.org/10.1029/2019MS001784)
</summary>

```
@article{dai2019global,
    author = {Dai, Yongjiu and Xin, Qinchuan and Wei, Nan and Zhang, Yonggen
        and Shangguan, Wei and Yuan, Hua and Zhang, Shupeng and Liu, Shaofeng
        and Lu, Xingjie},
	year = {2019},
    title = {A global high-resolution data set of soil hydraulic and thermal
        properties for land surface modeling},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {11},
	number = {9},
	pages = {2996--3023}
}


```
</details>
"""
struct VGMThetaSJules{FT} <: AbstractDataset{FT} end








###############################################################################
#
# Surface level land mark
#
###############################################################################
"""
    struct FloodPlainHeight{FT}

<details>
<summary>
Flood plain height
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct FloodPlainHeight{FT} <: AbstractDataset{FT} end




"""
    struct LandElevation{FT}

<details>
<summary>
Land elevation (height above mean sea level)
[Link to Dataset Source](https://doi.org/10.1002/2017GL072874)
</summary>

```
@article{yamazaki2017high,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Tawatari, Ryunosuke and
        Yamaguchi, Tomohiro and O'Loughlin, Fiachra and Neal, Jeffery C and
        Sampson, Christopher C and Kanae, Shinjiro and Bates, Paul D},
    year = {2017},
    title = {A high-accuracy map of global terrain elevations},
    journal = {Geophysical Research Letters},
    volume = {44},
    number = {11},
    pages = {5844--5853}
}
```
</details>
"""
struct LandElevation{FT} <: AbstractDataset{FT} end




"""
    struct LandMaskERA5{FT}

Struct for land mask from ERA5
"""
struct LandMaskERA5{FT} <: AbstractDataset{FT} end




"""
    struct RiverHeight{FT}

<details>
<summary>
River height
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct RiverHeight{FT} <: AbstractDataset{FT} end




"""
    struct RiverLength{FT}

<details>
<summary>
River length
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct RiverLength{FT} <: AbstractDataset{FT} end




"""
    struct RiverManning{FT}

<details>
<summary>
River manning coefficient
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct RiverManning{FT} <: AbstractDataset{FT} end




"""
    struct RiverWidth{FT}

<details>
<summary>
River width
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct RiverWidth{FT} <: AbstractDataset{FT} end




"""
    struct SurfaceAreaCLM{FT}

Struct for surface area from CLM
"""
struct SurfaceAreaCLM{FT} <: AbstractDataset{FT} end




"""
    struct UnitCatchmentArea{FT}

<details>
<summary>
Unit catchment area
[Link to Dataset Source](https://doi.org/10.1029/2019WR024873)
</summary>

```
@article{yamazaki2019merit,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Sosa, Jeison and Bates,
        Paul D and Allen, George H and Pavelsky, Tamlin M},
    year = {2019},
    title = {{MERIT} {H}ydro: {A} high-resolution global hydrography map based
        on latest topography dataset},
    journal = {Water Resources Research},
    volume = {55},
    number = {6},
    pages = {5053--5073}
}
```
</details>
"""
struct UnitCatchmentArea{FT} <: AbstractDataset{FT} end








###############################################################################
#
# General data struct
#
###############################################################################
"""
    struct GriddedDataset{FT<:AbstractFloat}

A general struct to store data

# Fields
$(FIELDS)
"""
Base.@kwdef struct GriddedDataset{FT<:AbstractFloat}
    "Gridded dataset"
    data::Array{FT,3} = zeros(360,180,1);
    "Realistic range"
    lims::Array{FT,1} = FT[-100,100]
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(data,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(data,1)
    "Time resolution: D-M-Y-C: day-month-year-century"
    res_time::String = "1Y"
    "Variable name"
    var_name::String = "ZEROS"
    "Variable attribute"
    var_attr::Dict{String,String} = Dict("longname" => "ZEROS",
                                         "units"    => "-")
    "Type label"
    dt::AbstractDataset = NPPModis{FT}()
end
