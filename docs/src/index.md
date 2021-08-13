# GriddingMachine

Global datasets to feed [CliMA Land](https://github.com/CliMA/Land) model.




## Install and use
```julia
using Pkg;
Pkg.add("GriddingMachine");
```

```@example preview
using GriddingMachine.Collections;

file = query_collection(VcmaxCollection(), "2X_1Y_V1");
@show file;
```
