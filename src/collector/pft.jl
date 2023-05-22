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
