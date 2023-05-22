"""

    latent_heat_collection()

<details>
<summary>
Method to create a general dataset collection for latent heat flux. Supported datasets are (click to view bibtex items)
- `MPI_RS_2X_8D_YYYY_V1` [(YYYY from 2001 to 2015; Jung et al., 2015)](https://doi.org/10.1038/s41597-019-0076-8)
- `MPI_RS_2X_1M_YYYY_V1` [(YYYY from 2001 to 2015; Jung et al., 2015)](https://doi.org/10.1038/s41597-019-0076-8)
</summary>

```
@article{jung2019fluxcom,
    author = {Jung, Martin and Koirala, Sujan and Weber, Ulrich and Ichii, Kazuhito and Gans, Fabian and Camps-Valls, Gustau and Papale, Dario and Schwalm, Christopher and Tramontana, Gianluca and
              Reichstein, Markus},
    year = {2019},
    title = {The {FLUXCOM} ensemble of global land-atmosphere energy fluxes},
    journal = {Scientific Data},
    volume = {6},
    number = {1},
    pages = {74}
}
```
</details>

"""
latent_heat_collection() = (
    _supported = [];
    for _year in 2001:2015
        push!(_supported, "MPI_RS_2X_8D_$(_year)_V1");
        push!(_supported, "MPI_RS_2X_1M_$(_year)_V1");
    end;

    return GriddedCollection("LE", _supported, "MPI_RS_2X_8D_2015_V1")
);
