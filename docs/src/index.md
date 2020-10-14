# GriddingMachine

Global datasets to feed [CliMA Land](https://github.com/CliMA/Land) model




## Usage
```julia
# not registered for now
using Pkg;
Pkg.add(PackageSpec(url="https://github.com/CliMA/GriddingMachine.jl.git", rev="main"));

using GriddingMachine

FT = Float32;
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
# read the lai at lat=30, lon=-100, month=Augest
lai_val = read_LUT(LAI_LUT, FT(30), FT(-100), 8);
@show lai_val;
```




## Collected Datasets

| Structure Name     | Artifact                     | Description                                             |
|:-------------------|:-----------------------------|:--------------------------------------------------------|
| CanopyHeightGLAS   | `canopy_height_0_05_deg`     | 1/2 degree resolution, year 2005                        |
| ClumpingIndexMODIS | `clumping_index_500_m`       | 1/240 degree resolution, year 2006                      |
| ClumpingIndexPFT   | `clumping_index_0_5_deg_PFT` | 1/2 degree resolution per PFT, year 2006                |
| GPPMPIv006         | `MPI_GPP_v006_0_5_deg_8D`    | 1/2 degree resolution per 8 days, year 2001-2019        |
|                    | `MPI_GPP_v006_0_5_deg_1M`    | 1/2 degree resolution per month, year 2001-2019         |
| GPPVPMv20          | `VPM_GPP_v20_0_2_deg_8D`     | 1/5 degree resolution per 8 days, year 2000-2019        |
|                    | `VPM_GPP_v20_0_083_deg_8D`   | 1/12 degree resolution per 8 days, year 2000-2019       |
| LAIMonthlyMean     | `lai_monthly_mean`           | 1/4 degree resolution per month, mean of year 1981-2015 |
| LeafNitrogen       | `leaf_sla_n_p_0_5_deg`       | 1/2 degree resolution, mean from report literature      |
| LeafPhosphorus     |                              |                                                         |
| LeafSLA            |                              |                                                         |
| NPPModis           | `npp_1_deg`                  | 1 degree resolution, year 2000                          |
| VcmaxOptimalCiCa   | `vcmax_0_5_deg`              | 1/2 degree resolution, derived from optimal Ci/Ca       |
