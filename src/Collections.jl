module Collections

using Artifacts: @artifact_str
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using LazyArtifacts


# export public types
export GriddedCollection, VcmaxCollection


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
vcmax_collection = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"]);
"""
struct GriddedCollection
    "Artifact label name"
    LABEL::String
    "Supported combinations"
    SUPPORTED_COMBOS::Vector{String}
end


# constructors for GriddedCollection
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
    author = {Smith, Nicholas G. and Keenan, Trevor F. and Prentice, I. Colin and Wang, Han and Wright, Ian J. and Niinemets, Ülo and
              Crous, Kristine Y. and Domingues, Tomas F. and Guerrieri, Rossella and {Yoko Ishida}, F. and Zhou, Shuangxi},
    year = {2019},
    title = {Global photosynthetic capacity is optimized to the environment},
    journal = {Ecology Letters},
    volume = {22},
    number = {3},
    pages = {506–517}
}
@article{luo2021global,
	author = {Luo, Xiangzhong and Keenan, Trevor F. and Chen, Jing M. and Croft, Holly and {Colin Prentice}, I. and Smith, Nicholas G. and
              Walker, Anthony P. and Wang, Han and Wang, Rong and Xu, Chonggang and Zhang, Yao},
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
