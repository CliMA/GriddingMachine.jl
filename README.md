# GriddingMachine.jl

<!-- Links and shortcuts -->
[wp-url]: https://github.com/CliMA/GriddingMachine.jl
[wp-api]: https://CliMA.github.io/GriddingMachine.jl/stable/API/
[cp-url]: https://github.com/CliMA/CLIMAParameters.jl

[dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[dev-url]: https://CliMA.github.io/GriddingMachine.jl/dev/

[rel-img]: https://img.shields.io/badge/docs-stable-blue.svg
[rel-url]: https://CliMA.github.io/GriddingMachine.jl/stable/

[st-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/JuliaStable/badge.svg?branch=master
[st-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"JuliaStable"

[bm-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Benchmarks/badge.svg?branch=master
[bm-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"Benchmarks"

[v13-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Julia-1.3/badge.svg?branch=master
[v13-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"Julia-1.3"

[v14-img]: https://github.com/CliMA/GriddingMachine.jl/workflows/Julia-1.4/badge.svg?branch=master
[v14-url]: https://github.com/CliMA/GriddingMachine.jl/actions?query=branch%3A"master"++workflow%3A"Julia-1.4"


## About

[`GriddingMachine.jl`][wp-url] includes a collection of global canopy propertie. Due to the use of `Base.@kwdef`, [`GriddingMachine.jl`][wp-url] only supports julia 1.3 and above.

| Documentation                                   | CI Status             | Benchmarks            | Compatibility                                   |
|:------------------------------------------------|:----------------------|:----------------------|:------------------------------------------------|
| [![][dev-img]][dev-url] [![][rel-img]][rel-url] | [![][st-img]][st-url] | [![][bm-img]][bm-url] | [![][v14-img]][v14-url] [![][v13-img]][v13-url] |




## Dependencies

| Dependency          | Version  | Requirements |
|:--------------------|:---------|:-------------|
| DocStringExtensions | 0.8.0 +  | Julia 0.7+   |
| HTTP                | 0.8.0 +  | Julia 0.7+   |
| NetCDF              | 0.10.0 + | Julia 1.2+   |
| GriddingMachine     | 0.1.0 +  | Julia 1.3+   |




## Installation
```julia
julia> using Pkg;
julia> Pkg.add("https://github.com/CliMA/GriddingMachine.jl.git");
```




## API
See [`API`][wp-api] for more detailed information about how to use [`GriddingMachine.jl`][wp-url].
