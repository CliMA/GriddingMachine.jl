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
