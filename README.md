# GriddingMachine.jl

<!-- Links and shortcuts -->
[gm-url]: https://github.com/CliMA/GriddingMachine.jl
[gm-api]: https://CliMA.github.io/GriddingMachine.jl/stable/API/

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://CliMA.github.io/GriddingMachine.jl/dev/

[st-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/JuliaStable/badge.svg?branch=main
[st-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"main"++workflow%3A"JuliaStable"

[cov-img]: https://codecov.io/gh/CliMA/GriddingMachine.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/CliMA/GriddingMachine.jl


## Credits
Please cite our paper(s) when you use GriddingMachine:

- Y. Wang, P. Köhler, R. K. Braghiere, M. Longo, R. Doughty, A. A. Bloom, and C. Frankenberg. 2022.
  GriddingMachine, a database and software for Earth system modeling at global and regional scales.
  Scientific Data. 9: 258.
  [DOI](https://doi.org/10.1038/s41597-022-01346-x)


## About
[`GriddingMachine.jl`][gm-url] distributes and reads a curated collection of global gridded datasets, and organizes them into inputs for land and Earth system models. It requires julia 1.10 and above.

| Documentation           | CI Status             | Code Coverage           |
|:------------------------|:----------------------|:------------------------|
| [![][dev-img]][dev-url] | [![][st-img]][st-url] | [![][cov-img]][cov-url] |


## Installation
```julia
julia> using Pkg;
julia> Pkg.add("GriddingMachine");
```


## API
GriddingMachine has the following sub-modules:
| Sub-module  | Functionality                                        | Ready to use |
|:------------|:-----------------------------------------------------|:-------------|
| Collector   | Maintain the catalog and download gridded datasets   | v0.5         |
| Indexer     | Read gridded datasets and organize model inputs      | v0.5         |
| Requestor   | Request site-level data from a GriddingMachine server | Experimental |
| Server      | Serve site-level data and a query page over HTTP      | v0.5         |

See [`API`][gm-api] for more detailed information about how to use [`GriddingMachine.jl`][gm-url].

To update the local catalog and download a dataset by its tag, use
```julia
julia> using GriddingMachine.Collector;
julia> Collector.update_database!();
julia> file_path = Collector.download_dataset!("VCMAX_2X_1Y_V1");
```

To read a whole dataset, a single grid cell, or one cycle of a 3D dataset, use
```julia
julia> using GriddingMachine.Indexer;
julia> data = Indexer.read_dataset("VCMAX_2X_1Y_V1");
julia> data = Indexer.read_dataset("VCMAX_2X_1Y_V1", 35.1, 115.2);
julia> data = Indexer.read_dataset("LAI_MODIS_2X_8D_2020_V1", 35.1, 115.2, 3);
```

To request a partial dataset from a running server without downloading the entire dataset, use
```julia
julia> using GriddingMachine.Requestor;
julia> dat,std = Requestor.request_site_data("http://localhost:8000", "user", "VCMAX_2X_1Y_V1", 35.1, 115.2);
```


## Query server

`GriddingMachine.Server` serves a small query page and three JSON endpoints:

```julia
julia> using GriddingMachine.Collector, GriddingMachine.Server;
julia> Collector.update_database!();
julia> Server.setup_url_input_routes!();
julia> Server.up_servers!(5055);
```

Then open `http://localhost:5055/`, or call the endpoints directly:

| Endpoint | Query parameters |
|:---------|:-----------------|
| `/sitedata.json` | `tag`, `lat`, `lon`, `cycle`, `include_std`, `user` |
| `/gmdict.json` | `gmversion` (`gm1`/`gm2`), `year`, `lat`, `lon`, `user` |
| `/weather.json` | `wdversion` (`wd1`), `year`, `lat`, `lon`, `user` |

`lat` and `lon` are required. Optional settings such as `cycle` or `include_std` fall back to a
default when they are missing or malformed, but coordinates never do: reporting a different
grid cell than the one asked about would be worse than refusing the request.

Stop the server with `Server.down_servers!()`.

**This server is meant for a local or trusted intranet network.** It binds `0.0.0.0` and has
no access control: the `user` parameter is a label written to the request log, not a
credential, and any caller can set it to any value. `/gmdict.json` and `/weather.json`
download whole dataset collections on first use, which can mean hundreds of megabytes per
request. Do not expose this server to an untrusted network.

Missing values are encoded as `-9999` in every response, because JSON has no NaN literal.
When a query needs datasets that are not registered in the local catalog, the response names
them under `MissingTags` instead of failing. An unknown tag is reported as a warning without
refreshing the catalog; call `Collector.update_database!()` to pick up new publications.

## Migrating from v0.4 to v0.5
v0.5 reorganizes the package around dataset distribution, reading, and model-input preparation. The changes that affect user code are:

| v0.4                                        | v0.5                                                        |
|:--------------------------------------------|:------------------------------------------------------------|
| `Collector.download_artifact!(tag)`         | `Collector.download_dataset!(tag)`                          |
| `Collector.query_collection(tag)`           | `Collector.dataset_path(tag)` / `Collector.dataset_info(tag)` |
| `Indexer.read_LUT(...)`                     | `Indexer.read_dataset(...)` (`read_LUT` kept as an alias)    |
| `Requestor.request_site_data(tag, lat, lon)` | `Requestor.request_site_data(server, user, tag, lat, lon)`  |
| `Blender.regrid(...)`                       | `using PkgUtility.MathTools: regrid`                        |
| `Fetcher` (download raw ungridded data)     | moved to [GriddingMachineDatasets](https://github.com/jhOo1/GriddingMachineDatasets) |

Other notes:
- `Blender`, `Fetcher`, `Partitioner`, and `Processer` are no longer part of the package. `Partitioner` and `Processer` were never enabled in v0.4. The remaining sources are kept under `deprecated/` for reference only.
- Catalog entries now carry `SIZE` and `SHA256`. Downloads are written to a cache first and only promoted to the public directory after the size and hash match, so an interrupted or corrupted download never replaces a valid file.
- One tag may list several mirror URLs; unreachable mirrors are skipped and the next candidate is tried.
- `using GriddingMachine` no longer creates directories or downloads the catalog as an import side effect. Call `Collector.initialize_database!()` or `Collector.update_database!()` explicitly.
- `Indexer` no longer interpolates between grid cells.


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
