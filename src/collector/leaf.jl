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
- `12X_1Y_V2` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
- `36X_1Y_V2` [(Moreno-Martinez et al., 2018)](https://doi.org/10.1016/j.rse.2018.09.006)
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
leaf_phosphorus_collection() = GriddedCollection("LPC", ["2X_1Y_V1", "12X_1Y_V2", "36X_1Y_V2"], "2X_1Y_V1");


"""

    sla_collection()

<details>
<summary>
Method to create a general dataset collection for SLA (specific leaf area). Supported datasets are (click to view bibtex items)
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
sla_collection() = GriddedCollection("SLA", ["2X_1Y_V1", "2X_1Y_V2", "12X_1Y_V3", "36X_1Y_V3"], "2X_1Y_V1");


"""

    vcmax_collection()

<details>
<summary>
Method to create a general dataset collection for Vcmax. Supported datasets are (click to view bibtex items)
- `2X_1Y_V1` [(Smith et al., 2019)](https://doi.org/10.1111/ele.13210)
- `2X_1Y_V2` [(Luo et al., 2019)](https://doi.org/10.1038/s41467-021-25163-9)
- `CESM_1X_1M_V3` CESM model output
- `CESM_LUNA_1X_1M_V3` CESM model output (LUNA model)
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
vcmax_collection() = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2", "CESM_1X_1M_V3", "CESM_LUNA_1X_1M_V3"], "2X_1Y_V2");
