# GriddingMachine

Global datasets to feed [CliMA Land](https://github.com/CliMA/Land) model.


## Install and use
```julia
using Pkg;
Pkg.add("GriddingMachine");
```

After installing GriddingMachine, you can use function `query_collection` from submodule Collector to query data.
The data will be automatically downloaded, and you will get the path to the data.

```@example preview
using GriddingMachine.Collector: query_collection;

file = query_collection("VCMAX_2X_1Y_V2");
@show file;
```

To read the data, you can use your preferred packages or our provided function `read_LUT` in submodule Indexer.
Function `read_LUT` returns a vector of data: data itself and std (NaN for missing data).

```@example preview
using GriddingMachine.Indexer: read_LUT;

data = read_LUT(file);
@show data;
```
