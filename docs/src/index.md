# GriddingMachine

Global canopy datasets

## Usage
```julia
# not registered for now
using Pkg;
Pkg.add(PackageSpec(url="https://github.com/CliMA/GriddingMachine.jl.git"));

using GriddingMachine

FT = Float32;
LAI_LUT = MeanMonthlyLAI{FT}();
# read the lai at lat=30, lon=-118, month=Augest
lai_val = read_LUT(LAI_LUT, FT(30), FT(-100), 8);
@show lai_val;
```
