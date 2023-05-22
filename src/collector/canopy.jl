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
- `20X_1M_V3` [(Wei et al., 2019)](https://doi.org/10.1016/j.rse.2019.111296)
- `2X_1M_V3` [(regridded; Wei et al., 2019)](https://doi.org/10.1016/j.rse.2019.111296)

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
@article{wei2019global,
    author = {Wei, Shanshan and Fang, Hongliang and Schaaf, Crystal B and He, Liming and Chen, Jing M},
    year = {2019},
    title = {Global 500 m clumping index product derived from MODIS BRDF data (2001--2017)},
    journal = {Remote Sensing of Environment},
    volume = {232},
    pages = {111296}
}
```
</details>

"""
clumping_index_collection() = GriddedCollection("CI", ["240X_1Y_V1", "2X_1Y_V1", "2X_1Y_V2", "20X_1M_V3"], "2X_1Y_V1");


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

    vegetation_cover_fraction()

<details>
<summary>
Method to create a general dataset collection for vegetation cover fraction. Supported datasets are (click to view bibtex items)
- `MODIS_MOD44B_2X_1Y_V1` [(DiMiceli et al., 2022)](https://doi.org/10.5067/MODIS/MOD44B.061)
</summary>

```
@article{dimiceli2022modismod44b,
    author = {DiMiceli, C. and Sohlberg, R. and Townshend, J.},
    doi = {10.5067/MODIS/MOD44B.061},
    year = {2022},
    title = {MODIS/Terra Vegetation Continuous Fields Yearly L3 Global 250m SIN Grid V061},
    journal = {NASA EOSDIS Land Processes DAAC}
}
```
</details>

"""
vegetation_cover_fraction() = GriddedCollection("VCF", ["MODIS_MOD44B_2X_1Y_$(_year)_V1" for _year in 2000:2021], "MODIS_MOD44B_2X_1Y_2021_V1");
