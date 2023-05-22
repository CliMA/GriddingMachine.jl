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

    land_mask_collection()

Method to create a general dataset collection for land mask. Supported datasets are (click to view bibtex items)
- `4X_1Y_V1` [(ERA5)]

"""
land_mask_collection() = GriddedCollection("LM", ["4X_1Y_V1"], "4X_1Y_V1");


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
