# GriddingMachine.jl

<!-- Links and shortcuts -->
[gm-url]: https://github.com/CliMA/GriddingMachine.jl
[gm-api]: https://CliMA.github.io/GriddingMachine.jl/stable/API/

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://CliMA.github.io/GriddingMachine.jl/dev/

[rel-img]: https://img.shields.io/badge/docs-stable-blue.svg
[rel-url]: https://CliMA.github.io/GriddingMachine.jl/stable/

[st-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/JuliaStable/badge.svg?branch=master
[st-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"JuliaStable"

[min-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Julia-1.3/badge.svg?branch=master
[min-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"Julia-1.3"

[cov-img]: https://codecov.io/gh/CliMA/GriddingMachine.jl/branch/master/graph/badge.svg
[cov-url]: https://codecov.io/gh/CliMA/GriddingMachine.jl

## About

[`GriddingMachine.jl`][gm-url] includes a collection of global canopy propertie. Due to the use of `Base.@kwdef`, [`GriddingMachine.jl`][gm-url] only supports julia 1.3 and above.

| Documentation                                   | CI Status             | Compatibility           | Code Coverage           |
|:------------------------------------------------|:----------------------|:------------------------|:------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][min-img]][min-url] | [![][cov-img]][cov-url] |




## Dependencies

| Dependency          | Version  | Requirements |
|:--------------------|:---------|:-------------|
| DocStringExtensions | 0.8.0 +  | Julia 0.7 +  |
| HTTP                | 0.8.0 +  | Julia 0.7 +  |
| NetCDF              | 0.10.0 + | Julia 1.2 +  |
| GriddingMachine     |          | Julia 1.3 +  |




## Installation
```julia
julia> using Pkg;
Pkg.add(PackageSpec(url="https://github.com/CliMA/GriddingMachine.jl.git"));
```




## API
See [`API`][gm-api] for more detailed information about how to use [`GriddingMachine.jl`][gm-url].
