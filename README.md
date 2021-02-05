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

[min-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Julia-1.5/badge.svg?branch=main
[min-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"main"++workflow%3A"Julia-1.5"

[cov-img]: https://codecov.io/gh/CliMA/GriddingMachine.jl/branch/main/graph/badge.svg
[cov-url]: https://codecov.io/gh/CliMA/GriddingMachine.jl

## About

[`GriddingMachine.jl`][gm-url] includes a collection of global canopy propertie. To best utilize `Pkg.Artifacts`, [`GriddingMachine.jl`][gm-url] only supports julia 1.5.0 and above.

| Documentation                                   | CI Status             | Compatibility           | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][min-img]][min-url] | [![][cov-img]][cov-url] |




## Installation
```julia
julia> using Pkg;
julia> Pkg.add(PackageSpec(url="https://github.com/CliMA/GriddingMachine.jl.git", rev="main"));
```




## API
See [`API`][gm-api] for more detailed information about how to use [`GriddingMachine.jl`][gm-url].
