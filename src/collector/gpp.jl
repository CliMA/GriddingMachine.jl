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
