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

We tried our best to make all these datasets publically available, so that we
reached the original data owners for their permission to share the data via
`GriddingMachine.jl`. Column `Agree to share` notes whether the data owner
authorized us to share the data. Given some technical issues (e.g., we were not
able to send out emails to some email addresses; wierd, but it happened to us),
we were not able to reach some data owners. Yet, we keep these datasets for
testing and scientific purpose. Therefore, users of this kind of datasets need
to reach the original data owner on their own.

| Structure Name     | Description                        | Resolutions | Year      | Source                  | Format | Credit (CliMA)   | Agree to share |
|:-------------------|:-----------------------------------|:------------|:----------|:------------------------|:-------|:-----------------|:---------------|
| CanopyHeightGLAS   | Mean canopy height                 | 20X-1Y      | NS        | Simard et al. (2011)    | NetCDF |                  | Yes            |
| ClumpingIndexMODIS | Clumping index (year 2006)         | 240X-1Y     | NS        | He et al. (2012)        | TIFF   |                  | NASA DATA      |
|                    |                                    | 12X-1Y      | NS        | regridded               | TIFF   | Yujie Wang       | Yes            |
| ClumpingIndexPFT   | Clumping index (year 2006) per PFT | 2X-1Y       | NS        | Braghiere et al. (2019) | NetCDF | Renato Braghiere | Yes            |
| FloodPlainHeight   | Flood plain height                 | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| GPPMPIv006         | Gross primary productivity         | 2X-8D       | 2001-2019 | Jung et al. (2020)      | NetCDF |                  | Yes            |
|                    |                                    | 2X-1M       | 2001-2019 | Jung et al. (2020)      | NetCDF |                  | Yes            |
|                    |                                    | 1X-8D       | 2001-2019 | regridded               | NetCDF | Yujie Wang       | Yes            |
| GPPVPMv20          |                                    | 12X-8D      | 2000-2019 | Zhang et al. (2017)     | NetCDF | Russell Doughty  | Yes            |
|                    |                                    | 5X-8D       | 2000-2019 | Zhang et al. (2017)     | NetCDF | Russell Doughty  | Yes            |
|                    |                                    | 1X-8D       | 2000-2019 | regridded               | NetCDF | Yujie Wang       | Yes            |
| LAIMonthlyMean     | Leaf area index (1981-2015 mean)   | 4X-1M       | NS        | Mao and Yan (2019)      | NetCDF | Yujie Wang       | NASA DATA      |
| LandElevation      | Land elevation                     | 4X-1Y       | NS        | Yamazaki et al. (2017)  | NetCDF | Jake Bolewski    | Email error    |
| LandMaskERA5       | Land mask                          | 4X-1Y       | NS        | regridded from ERA5     | NetCDF |                  | ERA5 DATA      |
| LeafChlorophyll    | Leaf chlorophyll content (mean)    | 2X-7D       | NS        | Croft et al. (2020)     | NetCDF | Russell Doughty  | Asked          |
| LeafNitrogen       | Leaf nitrogen content              | 2X-1Y       | NS        | Butler et al. (2017)    | NetCDF | Marcos Longo     | Asked+Waiting  |
| LeafPhosphorus     | Leaf phosphorus content            | 2X-1Y       | NS        | Butler et al. (2017)    | NetCDF | Marcos Longo     | Asked+Waiting  |
| LeafSLA            | Leaf area per mass                 | 2X-1Y       | NS        | Butler et al. (2017)    | NetCDF | Marcos Longo     | Asked+Waiting  |
| NPPModis           | Net primary productivity           |             |           |                         |        |                  |                |
| RiverHeight        | River height                       | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| RiverLength        | River length                       | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| RiverManning       | River manning coefficient          | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| RiverWidth         | River width                        | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| TreeDensity        | Tree number per area               | 120X-1Y     | NS        | Crowther et al. (2015)  | NetCDF | Renato Braghiere | Yes            |
|                    | Tree number per area               | 12X-1Y      | NS        | regridded               | TIFF   | Yujie Wang       | Yes            |
| UnitCatchmentArea  | Unit catchment area                | 4X-1Y       | NS        | Yamazaki et al. (2019)  | NetCDF | Jake Bolewski    | Email error    |
| VcmaxOptimalCiCa   | Vcmax from optimal Ci/Ca ratio     | 4X-1Y       | NS        | Smith et al. (2019)     | NetCDF | Renato Braghiere | Yes            |
| WoodDensity        | Wood density                       | 2X-1Y       | NS        | Boonman et al. (2020)   | TIFF   | Marcos Longo     | Yes            |
