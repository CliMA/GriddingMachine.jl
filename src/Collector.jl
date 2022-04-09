module Collector

using Artifacts: @artifact_str, load_artifacts_toml
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using LazyArtifacts

import Base: show


# export public types and constructors
export GriddedCollection
export biomass_collection, canopy_height_collection, clumping_index_collection, elevation_collection, gpp_collection, lai_collection, land_mask_collection, leaf_chlorophyll_collection,
       leaf_drymass_collection, leaf_nitrogen_collection, leaf_phosphorus_collection, pft_collection, sif_collection, sil_collection, soil_color_collection, soil_hydraulics_collection,
       sla_collection, surface_area_collection, tree_density_collection, vcmax_collection, wood_density_collection


# export public functions
export clean_collections!, query_collection, sync_collections!


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


show(io::IO, col::GriddedCollection) = (
    # display the label
    print(io, "\n");
    printstyled(io, "    LABEL           ", color=:light_magenta);
    print(io, " ⇨ \""* col.LABEL* "\"\n");

    # display the supported combos
    printstyled(io, "    SUPPORTED_COMBOS", color=:light_magenta);
    print(io," ⇨ [\n");
    for _i in eachindex(col.SUPPORTED_COMBOS)
        if _i < length(col.SUPPORTED_COMBOS)
            print(io, "                        \"" * col.SUPPORTED_COMBOS[_i] * "\",\n");
        else
            print(io, "                        \"" * col.SUPPORTED_COMBOS[_i] * "\"\n");
        end;
    end;
    print(io, "                       ]\n");

    # display the default combo
    printstyled(io, "    DEFAULT_COMBO   ", color=:light_magenta);
    print(io, " ⇨ \"" * col.DEFAULT_COMBO * "\"\n");

    return nothing
);


# constructors for GriddedCollection
"""
    biomass_collection()

<details>
<summary>
Method to create a general dataset collection for biomass. Supported datasets are (click to view bibtex items)
- `ROOT_120X_1Y_V1` [(Huang et al., 2021)](https://doi.org/10.5194/essd-13-4263-2021)
- `SHOOT_120X_1Y_V2` [(Santoro et al., 2021)](https://doi.org/10.5194/essd-13-3927-2021)
</summary>

```
@article{huang2021global,
	author = {Huang, Y. and Ciais, P. and Santoro, M. and Makowski, D. and Chave, J. and Schepaschenko, D. and Abramoff, R. Z. and Goll, D. S. and Yang, H. and Chen, Y. and Wei, W. and Piao, S.},
	year = {2021},
	title = {A global map of root biomass across the world's forests},
	journal = {Earth System Science Data},
	volume = {13},
	number = {9},
	pages = {4263–4274}
}
@article{santoro2021global,
	author = {Santoro, M. and Cartus, O. and Carvalhais, N. and Rozendaal, D. M. A. and Avitabile, V. and Araza, A. and de Bruin, S. and Herold, M. and Quegan, S. and Rodr{\\'\\i}guez-Veiga, P. and Balzter, H. and Carreiras, J. and Schepaschenko, D. and Korets, M. and Shimada, M. and Itoh, T. and {Moreno Mart{\\'\\i}nez}, {\\'A}. and Cavlovic, J. and {Cazzolla Gatti}, R. and da Concei{\\c c}\\~ao Bispo, P. and Dewnath, N. and Labri{\\`e}re, N. and Liang, J. and Lindsell, J. and Mitchard, E. T. A. and Morel, A. and {Pacheco Pascagaza}, A. M. and Ryan, C. M. and Slik, F. and {Vaglio Laurin}, G. and Verbeeck, H. and Wijaya, A. and Willcock, S.},
	year = {2021},
	title = {The global forest above-ground biomass pool for 2010 estimated from high-resolution satellite observations},
	journal = {Earth System Science Data},
	volume = {13},
	number = {8},
	pages = {3927--3950}
}
```
</details>
"""
biomass_collection() = GriddedCollection("BIOMASS", ["ROOT_120X_1Y_V1", "SHOOT_120X_1Y_V2"], "SHOOT_120X_1Y_V2");


"""
    canopy_height_collection()

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
canopy_height_collection() = GriddedCollection("CH", ["20X_1Y_V1", "2X_1Y_V2"], "20X_1Y_V1");


"""
    clumping_index_collection()

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
clumping_index_collection() = GriddedCollection("CI", ["240X_1Y_V1", "2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V1");


"""
    elevation_collection()

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
elevation_collection() = GriddedCollection("ELEV", ["4X_1Y_V1"], "4X_1Y_V1");


"""
    gpp_collection()

<details>
<summary>
Method to create a general dataset collection for gross primary productivity. Supported datasets are (click to view bibtex items)
- `MPI_RS_2X_1M_YYYY_V1` [(YYYY from 2001 to 2019; Tramontana et al., 2016)](https://doi.org/10.5194/bg-13-4291-2016)
- `MPI_RS_2X_8D_YYYY_V1` [(YYYY from 2001 to 2019; Tramontana et al., 2016)](https://doi.org/10.5194/bg-13-4291-2016)
- `VPM_5X_8D_YYYY_V2` [(YYYY from 2000 to 2019; Zhang et al., 2017)](https://doi.org/10.1038/sdata.2017.165)
- `VPM_12X_8D_YYYY_V2` [(YYYY from 2000 to 2019; Zhang et al., 2017)](https://doi.org/10.1038/sdata.2017.165)
</summary>

```
@article{tramontana2016predicting,
    author = {Tramontana, Gianluca and Jung, Martin and Schwalm, Christopher R and Ichii, Kazuhito and Camps-Valls, Gustau and R{\\'a}duly, Botond and Reichstein, Markus and Arain, M Altaf and
              Cescatti, Alessandro and Kiely, Gerard and others},
    year = {2016},
    title = {Predicting carbon dioxide and energy fluxes across global FLUXNET sites with regression algorithms},
    journal = {Biogeosciences},
    volume = {13},
    number = {14},
    pages = {4291--4313}
}
@article{zhang2017global,
    author = {Zhang, Yao and Xiao, Xiangming and Wu, Xiaocui and Zhou, Sha and Zhang, Geli and Qin, Yuanwei and Dong, Jinwei},
    year = {2017},
    title = {A global moderate resolution dataset of gross primary production of vegetation for 2000--2016},
    journal = {Scientific data},
    volume = {4},
    pages = {170165}
}
```
</details>
"""
gpp_collection() = (
    _supported = [];
    for _year in 2001:2019
        push!(_supported, "MPI_RS_2X_1M_$(_year)_V1");
        push!(_supported, "MPI_RS_2X_8D_$(_year)_V1");
    end;
    for _year in 2000:2019
        push!(_supported, "VPM_5X_8D_$(_year)_V2");
        push!(_supported, "VPM_12X_8D_$(_year)_V2");
    end;

    return GriddedCollection("GPP", _supported, "MPI_RS_2X_1M_2019_V1")
);


"""
    lai_collection()

<details>
<summary>
Method to create a general dataset collection for leaf area index. Supported datasets are (click to view bibtex items)
- `MODIS_2X_1M_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
- `MODIS_2X_8D_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
- `MODIS_10X_1M_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
- `MODIS_10X_8D_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
- `MODIS_20X_1M_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
- `MODIS_20X_8D_YYYY_V1` [(YYYY from 2000 to 2020; Yuan et al., 2011)](https://doi.org/10.1016/j.rse.2011.01.001)
</summary>

```
@article{yuan2011reprocessing,
	author = {Yuan, Hua and Dai, Yongjiu and Xiao, Zhiqiang and Ji, Duoying and Shangguan, Wei},
	year = {2011},
	title = {Reprocessing the MODIS Leaf Area Index products for land surface and climate modelling},
	journal = {Remote Sensing of Environment},
	volume = {115},
	number = {5},
	pages = {1171--1187}
}
```
</details>
"""
lai_collection() = (
    _supported = [];
    for _year in 2000:2020
        push!(_supported, "MODIS_2X_1M_$(_year)_V1");
        push!(_supported, "MODIS_2X_8D_$(_year)_V1");
        push!(_supported, "MODIS_10X_1M_$(_year)_V1");
        push!(_supported, "MODIS_10X_8D_$(_year)_V1");
        push!(_supported, "MODIS_20X_1M_$(_year)_V1");
        push!(_supported, "MODIS_20X_8D_$(_year)_V1");
    end;

    return GriddedCollection("LAI", _supported, "MODIS_2X_8D_2020_V1")
);


"""
    land_mask_collection()

Method to create a general dataset collection for land mask. Supported datasets are (click to view bibtex items)
- `4X_1Y_V1` [(ERA5)]
"""
land_mask_collection() = GriddedCollection("LM", ["4X_1Y_V1"], "4X_1Y_V1");


"""
    leaf_chlorophyll_collection()

<details>
<summary>
Method to create a general dataset collection for leaf chlorophyll content. Supported datasets are (click to view bibtex items)
- `2X_7D_V1` [(Croft et al., 2017)](https://doi.org/10.1016/j.rse.2019.111479)
</summary>

```
@article{croft2020global,
    author = {Croft, H and Chen, JM and Wang, R and Mo, G and Luo, S and Luo, X and He, L and Gonsamo, A and Arabian, J and Zhang, Y and others},
    year = {2020},
    title = {The global distribution of leaf chlorophyll content},
    journal = {Remote Sensing of Environment},
    volume = {236},
    pages = {111479},
}
```
</details>
"""
leaf_chlorophyll_collection() = (
    @warn "This dataset is only meant for those who has reached to the authors (Croft et al) for permissions. We (developers of GriddingMachine) are not responsible for unauthorized usage";

    return GriddedCollection("CHL", ["2X_7D_V1"], "2X_7D_V1")
);


"""
    leaf_drymass_collection()

<details>
<summary>
Method to create a general dataset collection for leaf dry mass content. Supported datasets are (click to view bibtex items)
- `12X_1Y_V1` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
- `36X_1Y_V1` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
</summary>

```
@article{moreno2018methodology,
	author = {Moreno-Mart{\\'i}nez, {\\'A}lvaro and Camps-Valls, Gustau and Kattge, Jens and Robinson, Nathaniel and Reichstein, Markus and van Bodegom, Peter and Kramer, Koen and
              Cornelissen, J Hans C and Reich, Peter and Bahn, Michael and others},
    year = {2018},
	title = {A methodology to derive global maps of leaf traits using remote sensing and climate data},
	journal = {Remote sensing of environment},
	volume = {218},
	pages = {69--88}
}
```
</details>
"""
leaf_drymass_collection() = (
    return GriddedCollection("LDMC", ["12X_1Y_V1", "36X_1Y_V1"], "12X_1Y_V1")
);


"""
    leaf_nitrogen_collection()

<details>
<summary>
Method to create a general dataset collection for leaf nitrogen content. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Butler et al., 2017)](https://doi.org/10.1073/pnas.1708984114)
- `2X_1Y_V2` [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
- `12X_1Y_V3` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
- `36X_1Y_V3` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
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
@article{moreno2018methodology,
	author = {Moreno-Mart{\\'i}nez, {\\'A}lvaro and Camps-Valls, Gustau and Kattge, Jens and Robinson, Nathaniel and Reichstein, Markus and van Bodegom, Peter and Kramer, Koen and
              Cornelissen, J Hans C and Reich, Peter and Bahn, Michael and others},
    year = {2018},
	title = {A methodology to derive global maps of leaf traits using remote sensing and climate data},
	journal = {Remote sensing of environment},
	volume = {218},
	pages = {69--88}
}
```
</details>
"""
leaf_nitrogen_collection() = GriddedCollection("LNC", ["2X_1Y_V1", "2X_1Y_V2", "12X_1Y_V3", "36X_1Y_V3"], "2X_1Y_V1");


"""
    leaf_phosphorus_collection()

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
leaf_phosphorus_collection() = GriddedCollection("LPC", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    pft_collection()

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
pft_collection() = GriddedCollection("PFT", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    sif_collection()

<details>
<summary>
Method to create a general dataset collection for solar-induced chlorophyll fluorescence. Supported datasets are (click to view bibtex items)
- `TROPOMI_683_5X_1M_YYYY_V2` [(YYYY from 2019 to 2019; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541)
- `TROPOMI_683_5X_8D_YYYY_V2` [(YYYY from 2019 to 2019; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541)
- `TROPOMI_683DC_5X_1M_YYYY_V2` [(YYYY from 2019 to 2019; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541)
- `TROPOMI_683DC_5X_8D_YYYY_V2` [(YYYY from 2019 to 2019; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541)
- `TROPOMI_740_1X_1M_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740_1X_8D_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740_5X_1M_YYYY_V1` [(YYYY from 2019 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740_5X_8D_YYYY_V1` [(YYYY from 2019 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740_12X_1M_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740_12X_8D_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_1X_1M_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_1X_8D_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_5X_1M_YYYY_V1` [(YYYY from 2019 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_5X_8D_YYYY_V1` [(YYYY from 2019 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_12X_1M_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `TROPOMI_740DC_12X_8D_YYYY_V1` [(YYYY from 2018 to 2020; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)
- `OCO2_757_5X_1M_YYYY_V3` [(YYYY from 2014 to 2020; Sun et al., 2017)](https://doi.org/10.1126/science.aam5747)
- `OCO2_757DC_5X_1M_YYYY_V3` [(YYYY from 2014 to 2020; Sun et al., 2017)](https://doi.org/10.1126/science.aam5747)
- `OCO2_771_5X_1M_YYYY_V3` [(YYYY from 2014 to 2020; Sun et al., 2017)](https://doi.org/10.1126/science.aam5747)
- `OCO2_771DC_5X_1M_YYYY_V3` [(YYYY from 2014 to 2020; Sun et al., 2017)](https://doi.org/10.1126/science.aam5747)
</summary>

```
@article{kohler2018global,
    author = {K{\\"o}hler, Philipp and Frankenberg, Christian and Magney, Troy S and Guanter, Luis and Joiner, Joanna and Landgraf, Jochen},
    year = {2018},
    title = {Global retrievals of solar-induced chlorophyll fluorescence with {TROPOMI}: {F}irst results and intersensor comparison to {OCO-2}},
    journal = {Geophysical Research Letters},
    volume = {45},
    number = {19},
    pages = {10,456--10,463}
}
@article{kohler2020global,
	author = {K{\\"o}hler, Philipp and Behrenfeld, Michael J and Landgraf, Jochen and Joiner, Joanna and Magney, Troy S and Frankenberg, Christian},
	year = {2020},
	title = {Global retrievals of solar-induced chlorophyll fluorescence at red wavelengths with {TROPOMI}},
	journal = {Geophysical Research Letters},
	volume = {47},
	number = {15},
	pages = {e2020GL087541}
}
@article{sun2017oco,
	author = {Sun, Ying and Frankenberg, Christian and Wood, Jeffery D and Schimel, DS and Jung, Martin and Guanter, Luis and Drewry, DT and Verma, Manish and Porcar-Castell, Albert and Griffis, Timothy J and others},
	year = {2017},
	title = {OCO-2 advances photosynthesis observation from space via solar-induced chlorophyll fluorescence},
	journal = {Science},
	volume = {358},
	number = {6360}
}
```
</details>
"""
sif_collection() = (
    _supported = [];
    for _year in 2018:2020
        push!(_supported, "TROPOMI_740_1X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740_1X_8D_$(_year)_V1");
        push!(_supported, "TROPOMI_740_5X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740_5X_8D_$(_year)_V1");
        push!(_supported, "TROPOMI_740_12X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740_12X_8D_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_1X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_1X_8D_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_5X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_5X_8D_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_12X_1M_$(_year)_V1");
        push!(_supported, "TROPOMI_740DC_12X_8D_$(_year)_V1");
    end;
    for _year in 2019:2019
        push!(_supported, "TROPOMI_683_5X_1M_$(_year)_V2");
        push!(_supported, "TROPOMI_683_5X_8D_$(_year)_V2");
        push!(_supported, "TROPOMI_683DC_5X_1M_$(_year)_V2");
        push!(_supported, "TROPOMI_683DC_5X_8D_$(_year)_V2");
    end;
    for _year in 2014:2020
        push!(_supported, "OCO2_757_5X_1M_$(_year)_V3");
        push!(_supported, "OCO2_757DC_5X_1M_$(_year)_V3");
        push!(_supported, "OCO2_771_5X_1M_$(_year)_V3");
        push!(_supported, "OCO2_771DC_5X_1M_$(_year)_V3");
    end;

    return GriddedCollection("SIF", _supported, "TROPOMI_740_1X_1M_2019_V1")
);


"""
    sil_collection()

<details>
<summary>
Method to create a general dataset collection for solar-induced luminescence. Supported datasets are (click to view bibtex items)
- `SIL_20X_1Y_V1` [(Köhler et al., 2021)](https://doi.org/10.1029/2021GL095227)
</summary>

```
@article{kohler2021mineral,
	author = {K{\\"o}hler, Philipp and Fischer, Woodward W and Rossman, George R and Grotzinger, John P and Doughty, Russell and Wang, Yujie and Yin, Yi and Frankenberg, Christian},
	year = {2021},
	title = {Mineral luminescence observed from space},
	journal = {Geophysical Research Letters},
	volume = {48},
	number = {19},
	pages = {e2021GL095227}
}
```
</details>
"""
sil_collection() = GriddedCollection("SIL", ["20X_1Y_V1"], "20X_1Y_V1");


"""
    sla_collection()

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
sla_collection() = GriddedCollection("SLA", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V1");


"""
    soil_color_collection()

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
soil_color_collection() = GriddedCollection("SC", ["2X_1Y_V1"], "2X_1Y_V1");


"""
    soil_hydraulics_collection()

<details>
<summary>
Method to create a general dataset collection for soil hydraulic parameters (saturated hydraulic conductance - KSAT, residual soil water content - SWCR, saturated soil water content - SWCS, van
    Genuchten α - VGA, van Genuchten n - VGN). Supported datasets are (click to view bibtex items)
- `SWCR_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCR_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCS_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `SWCS_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGA_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGA_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGN_120X_1Y_V1` [(Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `VGN_12X_1Y_V1` [(regridded; Dai et al., 2019)](https://doi.org/10.1029/2019MS001784)
- `KSAT_100X_1Y_V2` [(Gupta et al., 2021)](https://doi.org/10.1029/2020MS002242)
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
@article{gupta2021global,
	author = {Gupta, Surya and Lehmann, Peter and Bonetti, Sara and Papritz, Andreas and Or, Dani},
	year = {2021},
	title = {Global Prediction of Soil Saturated Hydraulic Conductivity Using Random Forest in a Covariate-Based GeoTransfer Function (CoGTF) Framework},
	journal = {Journal of Advances in Modeling Earth Systems},
	volume = {13},
	number = {4},
	pages = {e2020MS002242}
}
```
</details>
"""
soil_hydraulics_collection() = (
    _supported = ["SWCR_120X_1Y_V1", "SWCR_12X_1Y_V1", "SWCS_120X_1Y_V1", "SWCS_12X_1Y_V1", "VGA_120X_1Y_V1", "VGA_12X_1Y_V1", "VGN_120X_1Y_V1", "VGN_12X_1Y_V1", "KSAT_100X_1Y_V2"];

    return GriddedCollection("SOIL", _supported, "SWCS_12X_1Y_V1")
);


"""
    surface_area_collection()

<details>
<summary>
Method to create a general dataset collection for earth surface area. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
- `1X_1Y_V1` [(regridded; Lawrence and Chase, 2007)](https://doi.org/10.1029/2006JG000168)
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
surface_area_collection() = GriddedCollection("SA", ["2X_1Y_V1", "1X_1Y_V1"], "2X_1Y_V1");


"""
    tree_density_collection()

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
tree_density_collection() = GriddedCollection("TD", ["120X_1Y_V1", "2X_1Y_V1"], "2X_1Y_V1");


"""
    vcmax_collection()

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
vcmax_collection() = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V2");


"""
    wood_density_collection()

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
wood_density_collection() = GriddedCollection("WD", ["2X_1Y_V1"], "2X_1Y_V1");


# query file from gridded collections
"""
This function queries data path for a dataset, supported methods are

$(METHODLIST)

"""
function query_collection end


"""
    query_collection(ds::GriddedCollection)

This method queries the local data path from collection for the default data, given
- `ds` [`GriddedCollection`](@ref) type collection

---
# Examples
```julia
dat_file = query_collection(canopy_height_collection());
```
"""
query_collection(ds::GriddedCollection) = query_collection(ds, ds.DEFAULT_COMBO);


"""
    query_collection(ds::GriddedCollection, version::String)

This method queries the local data path from collection, given
- `ds` [`GriddedCollection`](@ref) type collection
- `version` Queried dataset version (must be in `ds.SUPPORTED_COMBOS`)

---
# Examples
```julia
dat_file = query_collection(canopy_height_collection(), "20X_1Y_V1");
```
"""
query_collection(ds::GriddedCollection, version::String) = (
    # make sure requested version is in the
    @assert version in ds.SUPPORTED_COMBOS "$(version)";

    # determine file name from label and supported version
    _fn = "$(ds.LABEL)_$(version)";

    return query_collection(_fn)
);


"""
    query_collection(artname::String)

This method queries the local data path from given artifact name
- `artname` Artifact name
"""
query_collection(artname::String) = (
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _artns = [_name for (_name,_) in _metas];
    @assert artname in _artns artname;

    return @artifact_str(artname) * "/$(artname).nc"
);


"""
This function cleans up the collections, supported methods are

    $(METHODLIST)
"""
function clean_collections! end


"""
    clean_collections!(selection::String="old")

This method cleans up all selected artifacts of GriddingMachine.jl (through identify the `GRIDDINGMACHINE` file in the artifacts), given
- `selection` A string indicating which artifacts to clean up
    - `old` Artifacts from an old version of GriddingMachine.jl (default)
    - `all` All Artifacts from GriddingMachine.jl

---
# Examples
```julia
clean_collections!();
clean_collections!("old");
clean_collections!("all");
```
"""
clean_collections!(selection::String="old") = (
    # read the SHA1 identifications in Artifacts.toml
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _hashs = [_meta["git-tree-sha1"] for (_,_meta) in _metas];

    # iterate through the artifacts and remove the old one that is not in current Artifacts.toml or remove all artifacts within GriddingMachine.jl
    _artifact_dirs = readdir("$(homedir())/.julia/artifacts");
    for _dir in _artifact_dirs
        if isdir("$(homedir())/.julia/artifacts/$(_dir)")
            if isfile("$(homedir())/.julia/artifacts/$(_dir)/GRIDDINGMACHINE")
                if selection == "all"
                    rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
                else
                    if !(_dir in _hashs)
                        rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
                    end;
                end;
            end;
        end;
    end;

    return nothing
);


"""
    clean_collections!(selection::Vector{String})

This method cleans up all selected artifacts in GriddingMachine.jl, given
- `selection` A vector of artifact names

---
# Examples
```julia
clean_collections!(["PFT_2X_1Y_V1"]);
```
"""
clean_collections!(selection::Vector{String}) = (
    # read the SHA1 identifications in Artifacts.toml
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _hashs = [_metas[_artn]["git-tree-sha1"] for _artn in selection];

    # iterate the artifact hashs to remove corresponding folder
    for _dir in _hashs
        rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
    end;

    return nothing
);


"""
    clean_collections!(selection::GriddedCollection)

This method cleans up all selected artifacts in GriddingMachine.jl, given
- `selection` A [`GriddedCollection`](@ref) type collection

---
# Examples
```julia
clean_collections!(pft_collection());
```
"""
clean_collections!(selection::GriddedCollection) = (
    clean_collections!(["$(selection.LABEL)_$(_ver)" for _ver in selection.SUPPORTED_COMBOS]);

    return nothing
);


"""
This function sync the collections (only suggested to use with GriddingMachine server), supported methods are

    $(METHODLIST)
"""
function sync_collections! end


"""
    sync_collections!(gcs::GriddedCollection)

Sync collection datasets to local drive, given
- `gc` [`GriddedCollection`](@ref) type collection
"""
sync_collections!(gc::GriddedCollection) = (
    for _version in gc.SUPPORTED_COMBOS
        query_collection(gc, _version);
    end;

    return nothing
);


"""
    sync_collections!()

Sync all datasets to local drive. This function is meant to initialize GriddingMachine server.
"""
sync_collections!() = (
    # loop through all datasets
    _functions = Function[biomass_collection, canopy_height_collection, clumping_index_collection, elevation_collection, gpp_collection, lai_collection, land_mask_collection,
                          leaf_chlorophyll_collection, leaf_nitrogen_collection, leaf_phosphorus_collection, pft_collection, sif_collection, sil_collection, soil_color_collection,
                          soil_hydraulics_collection, sla_collection, surface_area_collection, tree_density_collection, vcmax_collection, wood_density_collection];
    for _f in _functions
        sync_collections!(_f());
    end;

    return nothing
);


end # module
