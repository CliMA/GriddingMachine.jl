# GriddingMachine

Global datasets to feed [CliMA Land](https://github.com/CliMA/Land) model




## Install and use
```julia
using Pkg;
Pkg.add(PackageSpec(url="https://github.com/CliMA/GriddingMachine.jl.git", rev="main"));
```

```@example preview
using GriddingMachine

FT = Float32;
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());

# read the lai at lat=30, lon=-100, month=Augest
lai_val = read_LUT(LAI_LUT, FT(30), FT(-100), 8);
@show lai_val;
```




## Collected Datasets

| Structure Name     | Artifact                   | Description                                               |
|:-------------------|:---------------------------|:----------------------------------------------------------|
| CanopyHeightGLAS   | `canopy_height_20X_1Y`     | 1/20  degree resolution, year 2005                        |
| ClumpingIndexMODIS | `clumping_index_12X_1Y`    | 1/240 degree resolution, year 2006                        |
|                    | `clumping_index_240X_1Y`   | 1/240 degree resolution, year 2006                        |
| ClumpingIndexPFT   | `clumping_index_2X_1Y_PFT` | 1/2   degree resolution per PFT, year 2006                |
| GPPMPIv006         | `GPP_MPI_v006_2X_8D`       | 1/2   degree resolution per 8 days, year 2001-2019        |
|                    | `GPP_MPI_v006_2X_1M`       | 1/2   degree resolution per month, year 2001-2019         |
| GPPVPMv20          | `GPP_VPM_v20_5X_8D`        | 1/5   degree resolution per 8 days, year 2000-2019        |
|                    | `GPP_VPM_v20_12X_8D`       | 1/12  degree resolution per 8 days, year 2000-2019        |
| LAIMonthlyMean     | `leaf_area_index_4X_1M`    | 1/4   degree resolution per month, mean of year 1981-2015 |
| LeafChlorophyll    | `leaf_chlorophyll_2X_7D`   | 1/2   degree resolution per week, mean of year 2003-2011  |
| LeafNitrogen       | `leaf_traits_2X_1Y`        | 1/2   degree resolution, mean from report literature      |
| LeafPhosphorus     |                            |                                                           |
| LeafSLA            |                            |                                                           |
| NPPModis           | `NPP_MODIS_1X_1Y`          | 1/1   degree resolution, year 2000                        |
| TreeDensity        | `tree_density_12X_1Y`      | 1/12  degree resolution, derived from ML                  |
|                    | `tree_density_120X_1Y`     | 1/120 degree resolution, derived from ML                  |
| VcmaxOptimalCiCa   | `leaf_traits_2X_1Y`        | 1/2   degree resolution, derived from optimal Ci/Ca       |
