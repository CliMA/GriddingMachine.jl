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
    author = {Santoro, M. and Cartus, O. and Carvalhais, N. and Rozendaal, D. M. A. and Avitabile, V. and Araza, A. and de Bruin, S. and Herold, M. and Quegan, S. and Rodr{\\'\\i}guez-Veiga, P. and
              Balzter, H. and Carreiras, J. and Schepaschenko, D. and Korets, M. and Shimada, M. and Itoh, T. and {Moreno Mart{\\'\\i}nez}, {\\'A}. and Cavlovic, J. and {Cazzolla Gatti}, R. and
              da Concei{\\c c}\\~ao Bispo, P. and Dewnath, N. and Labri{\\`e}re, N. and Liang, J. and Lindsell, J. and Mitchard, E. T. A. and Morel, A. and {Pacheco Pascagaza}, A. M. and
              Ryan, C. M. and Slik, F. and {Vaglio Laurin}, G. and Verbeeck, H. and Wijaya, A. and Willcock, S.},
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
