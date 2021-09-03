module Collections

using Artifacts: @artifact_str
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using LazyArtifacts


# export public types and constructors
export GriddedCollection
export CanopyHeightCollection, ClumpingIndexCollection, ElevationCollection, LandMaskCollection, LeafNitrogenCollection, LeafPhosphorusCollection, PlantFunctionalTypeCollection, SoilColorCollection,
       SoilHydraulicsCollection, SpecificLeafAreaCollection, SurfaceAreaCollection, TreeDensityCollection, VcmaxCollection, WoodDensityCollection


# export public functions
export query_collection


# collection types
"""
$(TYPEDEF)

Structure for general gridded dataset collection.

# Fields
$(TYPEDFIELDS)

---
# Examples
```julia
vcmax_collection = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V2");
```
"""
struct GriddedCollection
    "Artifact label name"
    LABEL::String
    "Supported combinations"
    SUPPORTED_COMBOS::Vector{String}
    "Default combination"
    DEFAULT_COMBO::String
end


# constructors for GriddedCollection
"""
    CanopyHeightCollection()

<details>
<summary>
Method to create a general dataset collection for canopy height. Supported datasets are (click to view bibtex items)
- `20X_1Y_V1` [(Simard et al., 2011)](https://doi.org/10.1029/2011JG001708)
- `2X_1Y_V2` [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
</summary>

```
@article{simard2011mapping,
    author = {Simard, Marc and Pinto, Naiara and Fisher, Joshua B and Baccini, Alessandro},
    year = {2011},
    title = {Mapping forest canopy height globally with spaceborne lidar},
    journal = {Journal of Geophysical Research: Biogeosciences},
    volume = {116},
    number = {G4021}
}
@article{boonman2020assessing,
    author = {Boonman, Coline CF and Ben{\\'i}tez-L{\\'o}pez, Ana and Schipper, Aafke M and Thuiller, Wilfried and Anand, Madhur and Cerabolini, Bruno EL and Cornelissen, Johannes HC and
              Gonzalez-Melo, Andres and Hattingh, Wesley N and Higuchi, Pedro and others},
    year = {2020},
    title = {Assessing the reliability of predicted plant trait distributions at the global scale},
    journal = {Global Ecology and Biogeography},
    volume = {29},
    number = {6},
    pages = {1034--1051}
}
```
</details>
"""
CanopyHeightCollection() = GriddedCollection("CH", ["20X_1Y_V1", "2X_1Y_V2"], "20X_1Y_V1");


"""
    ClumpingIndexCollection()

<details>
<summary>
Method to create a general dataset collection for clumping index. Supported datasets are (click to view bibtex items)
- `240X_1Y_V1` [(He et al., 2012)](https://doi.org/10.1016/j.rse.2011.12.008)
- `2X_1Y_V1` [(regridded; He et al., 2012)](https://doi.org/10.1016/j.rse.2011.12.008)
- `2X_1Y_V2` [(Braghiere et al., 2019)](https://doi.org/10.1029/2018GB006135)

V2 dataset are classified for different plant functional types. The indices are Broadleaf, Needleleaf, C3 grasses, C4 grasses, and shrubland.
</summary>

```
@article{he2012global,
    author={He, Liming and Chen, Jing M and Pisek, Jan and Schaaf, Crystal B and Strahler, Alan H},
    year={2012},
    title={Global clumping index map derived from the MODIS BRDF product},
    journal={Remote Sensing of Environment},
    volume={119},
    pages={118--130}
}
@article{braghiere2019underestimation,
    author = {Braghiere, R{\\'e}nato Kerches and Quaife, T and Black, E and He, L and Chen, JM},
    year = {2019},
    title = {Underestimation of global photosynthesis in Earth System Models due to representation of vegetation structure},
    journal = {Global Biogeochemical Cycles},
    volume = {33},
    number = {11},
    pages = {1358--1369}
}
```
</details>
"""
ClumpingIndexCollection() = GriddedCollection("CI", ["240X_1Y_V1", "2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V1");


"""
    ElevationCollection()

<details>
<summary>
Method to create a general dataset collection for surface elevation. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Yamazaki et al., 2017)](https://doi.org/10.1002/2017GL072874)
</summary>

```
@article{yamazaki2017high,
    author = {Yamazaki, Dai and Ikeshima, Daiki and Tawatari, Ryunosuke and Yamaguchi, Tomohiro and O'Loughlin, Fiachra and Neal, Jeffery C and Sampson, Christopher C and Kanae, Shinjiro and
              Bates, Paul D},
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
ElevationCollection() = GriddedCollection("ELEV", ["4X_1Y_V1"], "4X_1Y_V1");


"""
    LandMaskCollection()

Method to create a general dataset collection for land mask. Supported datasets are (click to view bibtex items)
- `4X_1Y_V1` [(ERA5)]
"""
LandMaskCollection() = GriddedCollection("LM", ["4X_1Y_V1"], "4X_1Y_V1");


"""
    LeafNitrogenCollection()

<details>
<summary>
Method to create a general dataset collection for leaf nitrogen content. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Butler et al., 2017)](https://doi.org/10.1073/pnas.1708984114)
- `2X_1Y_V2` [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee, Arindam and Atkin, Owen K and Kattge, Jens and
              Amiaud, Bernard and others},
    year = {2017},
    title = {Mapping local and global variability in plant trait distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
@article{boonman2020assessing,
    author = {Boonman, Coline CF and Ben{\\'i}tez-L{\\'o}pez, Ana and Schipper, Aafke M and Thuiller, Wilfried and Anand, Madhur and Cerabolini, Bruno EL and Cornelissen, Johannes HC and
              Gonzalez-Melo, Andres and Hattingh, Wesley N and Higuchi, Pedro and others},
    year = {2020},
    title = {Assessing the reliability of predicted plant trait distributions at the global scale},
    journal = {Global Ecology and Biogeography},
    volume = {29},
    number = {6},
    pages = {1034--1051}
}
```
</details>
"""
LeafNitrogenCollection() = GriddedCollection("LNC", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V1");


"""
    LeafNitrogenCollection()

<details>
<summary>
Method to create a general dataset collection for leaf phosphorus content. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Butler et al., 2017)](https://doi.org/10.1073/pnas.1708984114)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee, Arindam and Atkin, Owen K and Kattge, Jens and
              Amiaud, Bernard and others},
    year = {2017},
    title = {Mapping local and global variability in plant trait distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
```
</details>
"""
LeafPhosphorusCollection() = GriddedCollection("LPC", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    PlantFunctionalTypeCollection()

<details>
<summary>
Method to create a general dataset collection for plant function type ratio. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
</summary>

```
@article{lawrence2007representing,
	author = {Lawrence, Peter J and Chase, Thomas N},
	year = {2007},
	title = {Representing a new MODIS consistent land surface in the Community Land Model (CLM 3.0)},
	journal = {Journal of Geophysical Research: Biogeosciences},
	volume = {112},
	pages = {G01023}
}
```
</details>
"""
PlantFunctionalTypeCollection() = GriddedCollection("PFT", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    SoilColorCollection()

<details>
<summary>
Method to create a general dataset collection for soil color class to use with soil albedo. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
</summary>

```
@article{lawrence2007representing,
    author = {Lawrence, Peter J and Chase, Thomas N},
    year = {2007},
    title = {Representing a new MODIS consistent land surface in the Community Land Model (CLM 3.0)},
    journal = {Journal of Geophysical Research: Biogeosciences},
    volume = {112},
    pages = {G01023}
}
```
</details>
"""
SoilColorCollection() = GriddedCollection("SC", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    SoilHydraulicsCollection()

<details>
<summary>
Method to create a general dataset collection for soil hydraulic parameters (residual soil water content - SWCR, saturated soil water content - SWCS, van Genuchten α - VGA, van Genuchten n - VGN).
    Supported datasets are (click to view bibtex items)
- `SWCR_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCR_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCS_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCS_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGA_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGA_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGN_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGN_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
</summary>

```
@article{dai2019global,
    author = {Dai, Yongjiu and Xin, Qinchuan and Wei, Nan and Zhang, Yonggen and Shangguan, Wei and Yuan, Hua and Zhang, Shupeng and Liu, Shaofeng and Lu, Xingjie},
	year = {2019},
    title = {A global high-resolution data set of soil hydraulic and thermal properties for land surface modeling},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {11},
	number = {9},
	pages = {2996--3023}
}
```
</details>
"""
SoilHydraulicsCollection() = GriddedCollection("SOIL", ["SWCR_120X_1Y_V1", "SWCR_12X_1Y_V1", "SWCS_120X_1Y_V1", "SWCS_12X_1Y_V1", "VGA_120X_1Y_V1", "VGA_12X_1Y_V1", "VGN_120X_1Y_V1",
                                                        "VGN_12X_1Y_V1"], "SWCS_12X_1Y_V1");


"""
    SpecificLeafAreaCollection()

<details>
<summary>
Method to create a general dataset collection for SLA (specific leaf area). Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Butler et al., 2017)](https://doi.org/10.1073/pnas.1708984114)
- `2X_1Y_V2` [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
</summary>

```
@article{butler2017mapping,
    author = {Butler, Ethan E and Datta, Abhirup and Flores-Moreno, Habacuc and Chen, Ming and Wythers, Kirk R and Fazayeli, Farideh and Banerjee, Arindam and Atkin, Owen K and Kattge, Jens and
              Amiaud, Bernard and others},
    year = {2017},
    title = {Mapping local and global variability in plant trait distributions},
    journal = {Proceedings of the National Academy of Sciences},
    volume = {114},
    number = {51},
    pages = {E10937--E10946}
}
@article{boonman2020assessing,
    author = {Boonman, Coline CF and Ben{\\'i}tez-L{\\'o}pez, Ana and Schipper, Aafke M and Thuiller, Wilfried and Anand, Madhur and Cerabolini, Bruno EL and Cornelissen, Johannes HC and
              Gonzalez-Melo, Andres and Hattingh, Wesley N and Higuchi, Pedro and others},
    year = {2020},
    title = {Assessing the reliability of predicted plant trait distributions at the global scale},
    journal = {Global Ecology and Biogeography},
    volume = {29},
    number = {6},
    pages = {1034--1051}
}
```
</details>
"""
SpecificLeafAreaCollection() = GriddedCollection("SLA", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V1");


"""
    SurfaceAreaCollection()

<details>
<summary>
Method to create a general dataset collection for earth surface area. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
- `2X_1Y_V1` [(regridded; Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
</summary>

```
@article{lawrence2007representing,
author = {Lawrence, Peter J and Chase, Thomas N},
year = {2007},
title = {Representing a new MODIS consistent land surface in the Community Land Model (CLM 3.0)},
journal = {Journal of Geophysical Research: Biogeosciences},
volume = {112},
pages = {G01023}
}
```
</details>
"""
SurfaceAreaCollection() = GriddedCollection("SA", ["2X_1Y_V1", "1X_1Y_V1"], "2X_1Y_V1");


"""
    TreeDensityCollection()

<details>
<summary>
Method to create a general dataset collection for tree density (number of trees per area). Supported datasets are (click to view bibtex items)
- `120X_1Y_V1` [(Crowther et al., 2017)](https://doi.org/10.1038/nature14967)
- `2X_1Y_V1` [(regridded; Crowther et al., 2020)](https://doi.org/10.1038/nature14967)
</summary>

```
@article{crowther2015mapping,
    author = {Crowther, Thomas W and Glick, Henry B and Covey, Kristofer R and Bettigole, Charlie and Maynard, Daniel S and Thomas, Stephen M and Smith, Jeffrey R and Hintler, Gregor and
              Duguid, Marlyse C and Amatulli, Giuseppe and others},
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
TreeDensityCollection() = GriddedCollection("TD", ["120X_1Y_V1", "2X_1Y_V1"], "2X_1Y_V1");


"""
    VcmaxCollection()

<details>
<summary>
Method to create a general dataset collection for Vcmax. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Smith et al., 2019)](https://doi.org/10.1111/ele.13210)
- `2X_1Y_V2` [(Luo et al., 2019)](https://doi.org/10.1038/s41467-021-25163-9)
</summary>

```
@article{smith2019global,
    author = {Smith, Nicholas G. and Keenan, Trevor F. and Prentice, I. Colin and Wang, Han and Wright, Ian J. and Niinemets, Ülo and Crous, Kristine Y. and Domingues, Tomas F. and
              Guerrieri, Rossella and {Yoko Ishida}, F. and Zhou, Shuangxi},
    year = {2019},
    title = {Global photosynthetic capacity is optimized to the environment},
    journal = {Ecology Letters},
    volume = {22},
    number = {3},
    pages = {506–517}
}
@article{luo2021global,
	author = {Luo, Xiangzhong and Keenan, Trevor F. and Chen, Jing M. and Croft, Holly and {Colin Prentice}, I. and Smith, Nicholas G. and Walker, Anthony P. and Wang, Han and Wang, Rong and
              Xu, Chonggang and Zhang, Yao},
	year = {2021},
	title = {Global variation in the fraction of leaf nitrogen allocated to photosynthesis},
	journal = {Nature Communications},
	volume = {12},
	number = {1},
	pages = {4866}
}
```
</details>
"""
VcmaxCollection() = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V2");


"""
    WoodDensityCollection()

<details>
<summary>
Method to create a general dataset collection for wood density. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
</summary>

```
@article{boonman2020assessing,
    author = {Boonman, Coline CF and Ben{\\'i}tez-L{\\'o}pez, Ana and Schipper, Aafke M and Thuiller, Wilfried and Anand, Madhur and Cerabolini, Bruno EL and Cornelissen, Johannes HC and
              Gonzalez-Melo, Andres and Hattingh, Wesley N and Higuchi, Pedro and others},
    year = {2020},
    title = {Assessing the reliability of predicted plant trait distributions at the global scale},
    journal = {Global Ecology and Biogeography},
    volume = {29},
    number = {6},
    pages = {1034--1051}
}
```
</details>
"""
WoodDensityCollection() = GriddedCollection("WD", ["2X_1Y_V1"], "2X_1Y_V1");


# query file from gridded collections
"""
This function queries data path for a dataset, supported methods are

$(METHODLIST)

"""
function query_collection end


"""
    query_collection(ds::GriddedCollection, version::String)

This method queries the local data path from collection, given
- `ds` [`GriddedCollection`](@ref) type collection
- `version` Queried dataset version (must be in `ds.SUPPORTED_COMBOS`)

---
# Examples
```julia
dat_file = query_collection(CanopyHeightCollection(), "20X_1Y_V1");
```
"""
query_collection(ds::GriddedCollection, version::String) = (
    # make sure requested version is in the
    @assert version in ds.SUPPORTED_COMBOS;

    # determine file name from label and supported version
    _fn = "$(ds.LABEL)_$(version)";

    return @artifact_str(_fn) * "/$(_fn).nc";
)


"""
    query_collection(ds::GriddedCollection)

This method queries the local data path from collection for the default data, given
- `ds` [`GriddedCollection`](@ref) type collection

---
# Examples
```julia
dat_file = query_collection(CanopyHeightCollection());
```
"""
query_collection(ds::GriddedCollection) = query_collection(ds, ds.DEFAULT_COMBO)


end
