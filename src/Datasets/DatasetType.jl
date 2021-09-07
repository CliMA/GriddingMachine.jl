###############################################################################
#
# Abstract dataset type
#
###############################################################################
"""
    abstract type AbstractDataset{FT}
"""
abstract type AbstractDataset{FT} end








###############################################################################
#
# Stand Level Datasets
#
###############################################################################
"""
    struct GPPVPMv20{FT}

<details>
<summary>
Struct for VPM GPP v20
[Link to Dataset Source](https://doi.org/10.1038/sdata.2017.165)
</summary>

```
@article{zhang2017global,
    author = {Zhang, Yao and Xiao, Xiangming and Wu, Xiaocui and Zhou, Sha and
        Zhang, Geli and Qin, Yuanwei and Dong, Jinwei},
    year = {2017},
    title = {A global moderate resolution dataset of gross primary production
        of vegetation for 2000--2016},
    journal = {Scientific data},
    volume = {4},
    pages = {170165}
}
```
</details>
"""
struct GPPVPMv20{FT} <: AbstractDataset{FT} end








###############################################################################
#
# General data struct
#
###############################################################################
"""
    struct GriddedDataset{FT<:AbstractFloat}

A general struct to store data

# Fields
$(FIELDS)
"""
Base.@kwdef struct GriddedDataset{FT<:AbstractFloat}
    "Gridded dataset"
    data::Array{FT,3} = zeros(360,180,1);
    "Realistic range"
    lims::Array{FT,1} = FT[-100,100]
    "Latitude resolution `[°]`"
    res_lat::FT = 180 / size(data,2)
    "Longitude resolution `[°]`"
    res_lon::FT = 360 / size(data,1)
    "Time resolution: D-M-Y-C: day-month-year-century"
    res_time::String = "1Y"
    "Variable name"
    var_name::String = "ZEROS"
    "Variable attribute"
    var_attr::Dict{String,String} = Dict("longname" => "ZEROS",
                                         "units"    => "-")
    "Type label"
    dt::AbstractDataset = GPPVPMv20{FT}()
end
