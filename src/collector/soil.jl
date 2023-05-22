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

    soil_texture_collection()

<details>
<summary>
Method to create a general dataset collection for soil texture. Supported datasets are (click to view bibtex items)
- `TEXTURE_1X_1Y_V1` [(Rodell et al., 2004)](https://doi.org/10.1175/BAMS-85-3-381)
</summary>

```
@article{rodell2004global,
    author = {Rodell, Matthew and Houser, PR and Jambor, UEA and Gottschalck, J and Mitchell, Kieran and Meng, C-J and Arsenault, Kristi and Cosgrove, B and Radakovich, J and Bosilovich, M and Entin, J K abd Walker, J P and Lohmann, D and Toll, D},
    year = {2004},
    title = {{The global land data assimilation system}},
    journal = {Bulletin of the American Meteorological Society},
    volume = {85},
    pages = {381--394}
}
```
</details>

"""
soil_texture_collection() = GriddedCollection("SOIL", ["TEXTURE_1X_1Y_V1", "TEXTURE_4X_1Y_V1"], "TEXTURE_1X_1Y_V1");
