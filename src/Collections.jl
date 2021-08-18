module Collections

using Artifacts: @artifact_str
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using LazyArtifacts


# export public types and constructors
export GriddedCollection
export CanopyHeightCollection, SpecificLeafAreaCollection, VcmaxCollection


# export public functions
export query_collection


# collection types
"""
$(TYPEDEF)

Structure for general gridded dataset collection.

# Fields
$(TYPEDFIELDS)

---
# Examples
```julia
vcmax_collection = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"]);
```
"""
struct GriddedCollection
    "Artifact label name"
    LABEL::String
    "Supported combinations"
    SUPPORTED_COMBOS::Vector{String}
end


# constructors for GriddedCollection
"""
    CanopyHeightCollection()

<details>
<summary>
Method to create a general dataset collection for canopy height. Supported datasets are (click to view bibtex items)
- 20X_1Y_V1 [(Simard et al., 2017)](https://doi.org/10.1029/2011JG001708)
- 2X_1Y_V2 [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
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
CanopyHeightCollection() = GriddedCollection("CH", ["20X_1Y_V1", "2X_1Y_V2"]);


"""
    SpecificLeafAreaCollection()

<details>
<summary>
Method to create a general dataset collection for SLA (specific leaf area). Supported datasets are (click to view bibtex items)
- 2X_1Y_V1 [(Butler et al., 2017)](https://doi.org/10.1073/pnas.1708984114)
- 2X_1Y_V2 [(Boonman et al., 2020)](https://doi.org/10.1111/geb.13086)
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
```
</details>
"""
SpecificLeafAreaCollection() = GriddedCollection("SLA", ["2X_1Y_V1", "2X_1Y_V2"]);


"""
    VcmaxCollection()

<details>
<summary>
Method to create a general dataset collection for Vcmax. Supported datasets are (click to view bibtex items)
- 2X_1Y_V1 [(Smith et al., 2019)](https://doi.org/10.1111/ele.13210)
- 2X_1Y_V2 [(Luo et al., 2019)](https://doi.org/10.1038/s41467-021-25163-9)
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
VcmaxCollection() = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"]);


# query file from gridded collections
"""
    query_collection(ds::GriddedCollection, version::String)

This method queries the Vcmax dataset localtion from collection, given
- `ds` [`GriddedCollection`](@ref) type collection
- `version` Queried dataset version (must be in `ds.SUPPORTED_COMBOS`)
"""
function query_collection(ds::GriddedCollection, version::String)
    # make sure requested version is in the
    @assert version in ds.SUPPORTED_COMBOS;

    # determine file name from label and supported version
    _fn = "$(ds.LABEL)_$(version)";

    return @artifact_str(_fn) * "/$(_fn).nc";
end


end
