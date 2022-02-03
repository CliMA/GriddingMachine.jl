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
