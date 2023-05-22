"""

    sif_collection()

<details>
<summary>
Method to create a general dataset collection for solar-induced chlorophyll fluorescence. Supported datasets are (click to view bibtex items)
- `TROPOMI_683_nX_1M_YYYY_V2` [(YYYY from 2018 to 2020; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541) n = [1,2,4,5,12]
- `TROPOMI_683_nX_8D_YYYY_V2` [(YYYY from 2018 to 2020; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541) n = [1,2,4,5,12]
- `TROPOMI_683DC_nX_1M_YYYY_V2` [(YYYY from 2018 to 2020; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541) n = [1,2,4,5,12]
- `TROPOMI_683DC_nX_8D_YYYY_V2` [(YYYY from 2018 to 2020; Köhler et al., 2020)](https://doi.org/10.1029/2020GL087541) n = [1,2,4,5,12]
- `TROPOMI_740_nX_1M_YYYY_V1` [(YYYY from 2018 to 2022; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031) n = [1,2,4,5,12]
- `TROPOMI_740_nX_8D_YYYY_V1` [(YYYY from 2018 to 2022; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031)) n = [1,2,4,5,12]
- `TROPOMI_740DC_nX_1M_YYYY_V1` [(YYYY from 2018 to 2022; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031) n = [1,2,4,5,12]
- `TROPOMI_740DC_nX_8D_YYYY_V1` [(YYYY from 2018 to 2022; Köhler et al., 2018)](https://doi.org/10.1029/2018GL079031) n = [1,2,4,5,12]
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
    for _year in 2018:2022
        for _nx in ["1X", "2X", "4X", "5X", "12X"]
            for _nt in ["1M", "8D"]
                push!(_supported, "TROPOMI_740_$(_nx)_$(_nt)_$(_year)_V1");
                push!(_supported, "TROPOMI_740DC_$(_nx)_$(_nt)_$(_year)_V1");
            end;
        end;
    end;
    for _year in 2018:2020
        for _nx in ["1X", "2X", "4X", "5X", "12X"]
            for _nt in ["1M", "8D"]
                push!(_supported, "TROPOMI_683_$(_nx)_$(_nt)_$(_year)_V2");
                push!(_supported, "TROPOMI_683DC_$(_nx)_$(_nt)_$(_year)_V2");
            end;
        end;
    end;
    for _year in 2014:2020
        for _nx in ["5X"]
            for _nt in ["1M"]
                push!(_supported, "OCO2_757_$(_nx)_$(_nt)_$(_year)_V3");
                push!(_supported, "OCO2_757DC_$(_nx)_$(_nt)_$(_year)_V3");
                push!(_supported, "OCO2_771_$(_nx)_$(_nt)_$(_year)_V3");
                push!(_supported, "OCO2_771DC_$(_nx)_$(_nt)_$(_year)_V3");
            end;
        end;
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
