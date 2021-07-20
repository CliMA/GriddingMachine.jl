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

| Structure Name      | Description                        | Resolutions | Year      | Source                    | Format | Credit (CliMA)   | Agree to share |
|:--------------------|:-----------------------------------|:------------|:----------|:--------------------------|:-------|:-----------------|:---------------|
| CanopyHeightGLAS    | Mean canopy height                 | 20X-1Y      | NS        | Simard et al. (2011)      | NetCDF | Marcos Longo     | Yes            |
| CanopyHeightBoonman | Mean canopy height                 | 20X-1Y      | NS        | Boonman et al. (2020)     | TIFF   | Marcos Longo     | Yes            |
| ClumpingIndexMODIS  | Clumping index (year 2006)         | 240X-1Y     | NS        | He et al. (2012)          | TIFF   | Renato Braghiere | NASA DATA      |
|                     |                                    | 12X-1Y      | NS        | regridded                 | TIFF   | Yujie Wang       | Yes            |
| ClumpingIndexPFT    | Clumping index (year 2006) per PFT | 2X-1Y       | NS        | Braghiere et al. (2019)   | NetCDF | Renato Braghiere | Yes            |
| GPPMPIv006          | Gross primary productivity         | 2X-8D       | 2001-2019 | Jung et al. (2020)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 2X-1M       | 2001-2019 | Jung et al. (2020)        | NetCDF | Yujie Wang       | Yes            |
| GPPVPMv20           |                                    | 12X-8D      | 2000-2019 | Zhang et al. (2017)       | NetCDF | Russell Doughty  | Yes            |
|                     |                                    | 5X-8D       | 2000-2019 | Zhang et al. (2017)       | NetCDF | Russell Doughty  | Yes            |
| LAIMODISv006        | Leaf area index                    | 2X-1M       | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 10X-1M      | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 20X-1M      | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 2X-8D       | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 10X-8D      | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
|                     |                                    | 20X-8D      | 2000-2020 | Yuan et al. (2011)        | NetCDF | Yujie Wang       | Yes            |
| LAIMonthlyMean      | Leaf area index (1981-2015 mean)   | 4X-1M       | NS        | Mao and Yan (2019)        | NetCDF | Yujie Wang       | NASA DATA      |
| LandMaskERA5        | Land mask                          | 4X-1Y       | NS        | regridded from ERA5       | NetCDF | Yujie Wang       | ERA5 DATA      |
| LeafNitrogenButler  | Leaf nitrogen content              | 2X-1Y       | NS        | Butler et al. (2017)      | NetCDF | Marcos Longo     | Yes            |
| LeafNitrogenBoonman | Leaf nitrogen content              | 2X-1Y       | NS        | Boonman et al. (2020)     | TIFF   | Marcos Longo     | Yes            |
| LeafPhosphorus      | Leaf phosphorus content            | 2X-1Y       | NS        | Butler et al. (2017)      | NetCDF | Marcos Longo     | Yes            |
| LeafSLAButler       | Leaf area per mass                 | 2X-1Y       | NS        | Butler et al. (2017)      | NetCDF | Marcos Longo     | Yes            |
| LeafSLABoonman      | Leaf area per mass                 | 2X-1Y       | NS        | Boonman et al. (2020)     | TIFF   | Marcos Longo     | Yes            |
| NDVIAvhrr           | NDVI from AVHRR                    | 20X-1M      | 1981-2020 | regridded                 | NetCDF | Yujie Wang       | Yes            |
| NIRoAvhrr           | NIRv with offset from AVHRR        | 20X-1M      | 1981-2020 | regridded                 | NetCDF | Yujie Wang       | Yes            |
| NIRvAvhrr           | NIRv from AVHRR                    | 20X-1M      | 1981-2020 | regridded                 | NetCDF | Yujie Wang       | Yes            |
| NPPModis            | Net primary productivity           |             |           |                           |        |                  |                |
| PFTPercentCLM       | PFT percentage in a pixel          | 2X-1Y       | NS        | Lawrence and Chase (2007) | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           | regridded                 |        | Yujie Wang       | Yes            |
| SoilColor           | Soil color classes                 | 2X-1Y       | NS        | Lawrence and Chase (2007) | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           | regridded                 |        | Yujie Wang       | Yes            |
| TreeDensity         | Tree number per area               | 120X-1Y     | NS        | Crowther et al. (2015)    | TIFF   | Renato Braghiere | Yes            |
|                     | Tree number per area               | 12X-1Y      | NS        | regridded                 | TIFF   | Yujie Wang       | Yes            |
| VcmaxOptimalCiCa    | Vcmax from optimal Ci/Ca ratio     | 4X-1Y       | NS        | Smith et al. (2019)       | NetCDF | Renato Braghiere | Yes            |
| VGMAlphaJules       | van Genuchten alpha of JULES       | 120X-1Y     | NS        | Dai et al. (2019)         | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           |                           |        | Yujie Wang       | Yes            |
|                     |                                    | 12X-1Y      |           | regridded                 |        | Yujie Wang       | Yes            |
| VGMLogNJules        | van Genuchten log(n) of JULES      | 120X-1Y     | NS        | Dai et al. (2019)         | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           |                           |        | Yujie Wang       | Yes            |
|                     |                                    | 12X-1Y      |           | regridded                 |        | Yujie Wang       | Yes            |
| VGMRWCRJules        | Residual SWC of JULES              | 120X-1Y     | NS        | Dai et al. (2019)         | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           |                           |        | Yujie Wang       | Yes            |
|                     |                                    | 12X-1Y      |           | regridded                 |        | Yujie Wang       | Yes            |
| VGMRWCSJules        | Saturated SWC of JULES             | 120X-1Y     | NS        | Dai et al. (2019)         | NetCDF | Renato Braghiere | Yes            |
|                     |                                    |             |           |                           |        | Yujie Wang       | Yes            |
|                     |                                    | 12X-1Y      |           | regridded                 |        | Yujie Wang       | Yes            |
| WoodDensity         | Wood density                       | 2X-1Y       | NS        | Boonman et al. (2020)     | TIFF   | Marcos Longo     | Yes            |
|||||||||
