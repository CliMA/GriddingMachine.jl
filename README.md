# GriddingMachine.jl

<!-- Links and shortcuts -->
[gm-url]: https://github.com/CliMA/GriddingMachine.jl
[gm-api]: https://CliMA.github.io/GriddingMachine.jl/stable/API/

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://CliMA.github.io/GriddingMachine.jl/dev/

[rel-img]: https://img.shields.io/badge/docs-stable-blue.svg
[rel-url]: https://CliMA.github.io/GriddingMachine.jl/stable/

[st-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/JuliaStable/badge.svg?branch=main
[st-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"main"++workflow%3A"JuliaStable"

[min-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Julia-1.6/badge.svg?branch=main
[min-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"main"++workflow%3A"Julia-1.6"

[cov-img]: https://codecov.io/gh/CliMA/GriddingMachine.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/CliMA/GriddingMachine.jl


## Credits
Developers and/or maintainers have invested a lot of time into this project. Since GriddingMachine.jl has not yet been published, if you use GriddingMachine in your publications, please consider
    sharing authorship with us.


## About
[`GriddingMachine.jl`][gm-url] includes a collection of global canopy propertie. To best utilize `Pkg.Artifacts` and FTP storage, [`GriddingMachine.jl`][gm-url] only supports julia 1.6 and above.

| Documentation                                   | CI Status             | Compatibility           | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][min-img]][min-url] | [![][cov-img]][cov-url] |


## Installation
```julia
julia> using Pkg;
julia> Pkg.add("GriddingMachine");
```


## API
GriddingMachine has the following sub-modules, some of which are in development. The sub-modules are
| Sub-module  | Functionality                   | Ready to use |
|:------------|:--------------------------------|:-------------|
| Blender     | Regrid the gridded datasets     | Testing      |
| Collector   | Distribute the gridded datasets | v0.2         |
| Fetcher     | Download ungridded datasets     | Testing      |
| Indexer     | Read the gridded datasets       | v0.2         |
| Partitioner | Sort the ungridded datasets     | Testing      |
| Requestor   | Request gridded datasets        | v0.2         |

See [`API`][gm-api] for more detailed information about how to use [`GriddingMachine.jl`][gm-url].

To automatically download and query the file path of the dataset, use
```julia
julia> GriddingMachine.Collector;
julia> file_path = query_collection('VCMAX_2X_1Y_V1');
```

To request a partial dataset from the server without download the entire dataset, use
```julia
julia> GriddingMachine.Requestor;
julia> dat,std = request_LUT('VCMAX_2X_1Y_V1', 35.1, 115.2);
julia> dat,std = request_LUT('VCMAX_2X_1Y_V1', 35.1, 115.2; interpolation=true);
```


## Other language supports
| Language | Link to Github repository                                                   |
|:---------|:----------------------------------------------------------------------------|
| Matlab   | [octave-griddingmachine](https://github.com/Yujie-W/octave-griddingmachine) |
| Octave   | [octave-griddingmachine](https://github.com/Yujie-W/octave-griddingmachine) |
| R        | [r-griddingmachine](https://github.com/Yujie-W/r-griddingmachine)           |
| Python   | [python-griddingmachine](https://github.com/Yujie-W/python-griddingmachine) |


## Data contribution
We welcome the contribution of global scale datasets to `GriddingMachine.jl`. To maximally promote data reuse, we ask data owners to preprocess your datasets before sharing with us, the requirements
    are:
- The dataset is stored in a NetCDF file
- The dataset is either a 2D or 3D array
- The dataset is cylindrically projected (WGS84 projection)
- The first dimension of the dataset is longitude
- The second dimension of the dataset is latitude
- The third dimension (if available) is the cycle index, e.g., time
- The longitude is oriented from west to east hemisphere (-180° to 180°)
- The latitude is oriented from south to north hemisphere (-90° to 90°)
- The dataset covers the entire globe (missing data allowed)
- Missing data is labeled as NaN (not a number) rather than an unrealistic fill value
- The dataset is not scaled (linearly, exponentially, or logarithmically)
- The dataset has common units, such as μmol m⁻² s⁻¹ for maximum carboxylation rate
- The spatial resolution is uniform longitudinally and latitudinally, e.g., both at 1/2°
- The spatial resolution is an integer division of 1°, such as 1/2°, 1/12°, 1/240°
- Each grid cell represents the average value of everything inside the grid cell area (as opposing to a single point in the middle of the cell)
- The label for the data is "data" (for conveniently loading the data)
- The label for the error is "std" (for conveniently loading the error)
- The dataset must contain one data array and one error array besides the dimensions
- The dataset contains citation information in the attributes
- The dataset contains a log summarizing changes if different from original source

The reprocessed NetCDF file should contain (only) the following fields:
| Field | Dimension | Description                           | Attributes   |
|:------|:----------|:--------------------------------------|:-------------|
| lon   | 1D        | Longitude in the center of a grid     | unit         |
|       |           |                                       | description  |
| lat   | 1D        | Latitude in the center of a grid      | unit         |
|       |           |                                       | description  |
| ind   | 1D        | Cycle index (for 3D data only)        | unit         |
|       |           |                                       | description  |
| data  | 2D/3D     | Data in the center of a grid          | longname     |
|       |           |                                       | unit         |
|       |           |                                       | about        |
|       |           |                                       | authors      |
|       |           |                                       | year         |
|       |           |                                       | title        |
|       |           |                                       | journal      |
|       |           |                                       | doi          |
|       |           |                                       | changeN      |
| std   | 2D/3D     | Error of data in the center of a grid | same as data |
|||||

For data contributors who have limited knowledge about Github and Julia, we recommend to contribute your reprocessed data to us by tag an issue via the button
    [New issue](https://github.com/CliMA/GriddingMachine.jl/issues) in the Issues Tab. See an example table [here](https://github.com/CliMA/GriddingMachine.jl/issues/62#issuecomment-1097063134). See
    [this google doc](https://docs.google.com/document/d/1Q1M9SZAG_domwy8Awe5iFNZRv53RDkNG29qVuQQFYG4/edit?usp=sharing) for an example of this data reprocessing and deployment.

For data contributors who are experienced Github and Julia users, we also welcome that your contribution of code directly. See this [pull request](https://github.com/CliMA/GriddingMachine.jl/pull/68)
    for an example of the pull request.
