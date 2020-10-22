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

An alternative `view` method is provided in parallel with `read_LUT`. The
    difference is that there is no memory allocation using `view_LUT` so that
    changes can be made directly to the `view`, whereas `read_LUT` creates new
    number or arrays and changes cannot be made to original data directly.

```@docs
view_LUT
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




## Gridding RAW data

### RAW dataset types

Currently, `GriddingMachine` supports the following raw dataset types:

```@docs
AbstractUngriddedData
```

The 500 m resolution datasets include
```@docs
AbstractMODIS500m
MODISv006LAI
```

The 1 km resolution datasets include
```@docs
AbstractMODIS1km
```

### Steps to grid RAW data

`GriddingMachine` allows to grid the data in a multiple threading manner, to
    realize this while avoid extensive memory quota, some CSV cache files will
    be created during the process (with the risk of high disk usage). To
    make it more user friendly, a customized function is used to dynamically
    regulate the number of threadings:

```@docs
dynamic_workers
```

However, because the MODIS tile information file is very large (e.g., 500 m
    resolution tile infomation takes up to >40 GB memory to load), the tile
    matricies (for both latitude and longitude) will not be loaded a priori. To
    load the tile matricies, you will need to call `load_MODIS!` function
    manually,

```@docs
load_MODIS!
```

Note that, if you want to load the matricies in every thread, you will need
    command like `@everywhere load_MODIS!(MODISv006LAI{Float32}())`. What the
    command does is loading 500 m resolution tiles information to every thread
    (worker). If you pass a 1 km data set type to `load_MODIS!`, it will load
    1 km resolution tiles information automatically, you don't need to worry
    about it. However, be cautious to use corresponding tile information for
    your project.

Once the tile information is loaded, you may query the files you want to work
    on using `query_RAW`, which returns an array of paramters to pass to
    different threads.

```@docs
query_RAW
```

Next, you should be able to grid the RAW files using [`grid_RAW`](@ref), which
    extract tile information from file name using `parse_HV`

```@docs
parse_HV
```

Then, [`grid_RAW`](@ref) will match the data information with tile latitude and
    longitude, and save the data to cache CSV files, which will stay on your
    hard drive until you remove them manually.

```@docs
grid_RAW
```

The last step you need is to read the cache CSV files and compile them to nc
    datasets. As the file may be extremely large for very high resolution data
    (e.g., 500 m), files are again stored as cache nc files, and then they will
    be compile into one nc file.

```@docs
compile_RAW
```

The disadvantage is that you need a huge space to store the cache file, whereas
    the advantages are

- all cache files can be reused, no recalculation is required if you need to
    grid the data to another resolution
- if you encounter any error (e.g., memory shortage), you don't need to redo
    the calculations for cached files
- you can run the gridding and compiling in multi-thread manner
