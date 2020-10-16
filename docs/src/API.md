# API
```@meta
CurrentModule = GriddingMachine
```




## Datasets for CliMA Look-Up-Table

All data are stored in a general structure, but they are catergorized to
    different data types. The general data structure is

```@docs
GriddedDataset
```

Note it here that the `dt` field in [`GriddedDataset`](@ref) is the data
    identity of the stored `data`. Please refer the lists below




## Dataset types

Current supported dataset formats are

```@docs
AbstractFormat
FormatNC
FormatTIFF
```

### General type

```@docs
AbstractDataset
```

### Leaf level dataset

```@docs
AbstractLeafDataset
LeafChlorophyll
LeafNitrogen
LeafPhosphorus
LeafSLA
VcmaxOptimalCiCa
```

### Stand level datasets

```@docs
AbstractStandDataset
CanopyHeightGLAS
ClumpingIndexMODIS
ClumpingIndexPFT
GPPMPIv006
GPPVPMv20
LAIMonthlyMean
LandMaskERA5
NPPModis
TreeDensity
```




## LOAD and READ Look-Up-Table

Griddingmachine package allows for reading data from both the artifact and
    local files. To read the artifacts, function [`query_LUT`](@ref) is
    provided:

```@docs
query_LUT
```

A general function is provided to load the look-up tables. Before you load the
    table, you need to know what data you want to read (see
    [`AbstractDataset`](@ref)), data from which year (required for some
    datasets), geophysical resolution (required for some datasets), and time
    resolution (resuired for some datasets). Also, if you want to load local
    files, you need to know the file name, dataset format, and the dataset
    label (e.g., variable name in *.nc files, or band number in *.tif files).
    Be aware that some datasets may be very big, be patient when downloading
    the data files. Also, you need to use computers or servers with enough
    memory, otherwise the program may crash when loading the data.

```@docs
load_LUT
```

The loaded data may contain null values filled with different default values.
    To remove these unexpected data, a general function is provided to mask out
    these values.

```@docs
mask_LUT!
```

A general function is provided to read the look-up tables. Note that you need
    to use realistic latitude, longitude, and index (required for some
    datasets) to read the data properly. For example, latitude must be within
    the range of `[-90,90]`, longitude must be within the range of `[-180,180]`
    or `[0,360]`, and index must be in `[1,12]` if you use it as month or
    `[0,46]` if you read the 8-day products. The functions [`lat_ind`](@ref)
    and [`lon_ind`](@ref) help convert latitude and longitude into index,
    respectively.

```@docs
read_LUT
lat_ind
lon_ind
```




## Regrid the Look-Up-Table

For better matching the gridded data, we also provide a function to regrid the
    dataset.

```@docs
regrid_LUT
```




## Save the Look-Up-Table

To avoid unnecessary reading or regridding the dataset, a function is provided
    to save the dataset to `.nc` file

```@docs
save_LUT
```
