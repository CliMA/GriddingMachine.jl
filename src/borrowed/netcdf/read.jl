#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Feb-03: add recursive variable query feature
#     2023-Feb-23: migrate from JuliaUtility to Emerald
#
#######################################################################################################################################################################################################
"""

    find_variable(ds::Dataset, var_name::String)

Return the path to dataset if it exists, given
- `ds` NCDatasets.Dataset type dataset
- `var_name` Variable to read

"""
function find_variable(ds::Dataset, var_name::String)
    # if var_name is in the current dataset, return it
    if var_name in keys(ds)
        return ds[var_name]
    end;

    # loop through the groups and find the data
    _dvar = nothing;
    for _group in keys(ds.group)
        _dvar = find_variable(ds.group[_group], var_name)
        if _dvar !== nothing
            break;
        end;
    end;

    # return the variable if it exists, otherwise return nothing
    return _dvar
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Feb-03: add recursive variable query feature
#     2022-Feb-03: add option to read raw data to avoid NCDatasets transform errors
#     2022-Feb-04: allow to read value from 1D array as well
#     2023-Feb-23: migrate from JuliaUtility to Emerald
# Bug fixes
#     2021-Dec-24: fix the bug that reads integer as float (e.g., ind)
#     2022-Jan-20: add dimension control to avoid errors
#
#######################################################################################################################################################################################################
"""

    read_nc(file::String, var_name::String; transform::Bool = true)
    read_nc(T, file::String, var_name::String; transform::Bool = true)

Read entire data from NC file, given
- `file` Path of the netcdf dataset
- `var_name` Variable to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

#
    read_nc(file::String, var_name::String, indz::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true)

Read a subset from nc file, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indz` The 3rd index of subset data to read
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

Note that the dataset must be a 1D or 3D array to use this method.

#
    read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true)

Read the subset data for a grid, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

#
    read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)
    read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true)

Read the data at a grid, given
- `file` Path of the netcdf dataset
- `var_name` Variable name
- `indx` The 1st index of subset data to read, typically longitude
- `indy` The 2nd index of subset data to read, typically latitude
- `indz` The 3rd index of subset data to read, typically time
- `transform` If true, transform the data using NCDatasets rules, otherwise read the raw data
- `T` Number type

---
# Examples
```julia
# read data labeled as test from test.nc
save_nc!("test.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data = read_nc("test.nc", "test");
data = read_nc(Float32, "test.nc", "test");

# read 1st layer data labeled as test from test.nc
data = read_nc("test.nc", "test", 1);
data = read_nc(Float32, "test.nc", "test", 1);

# read the data (time series) at a grid
save_nc!("test1.nc", "test", rand(36,18), Dict("description" => "Random randoms"));
save_nc!("test2.nc", "test", rand(36,18,12), Dict("description" => "Random randoms"));
data1 = read_nc("test1.nc", "test", 1, 1);
data2 = read_nc("test2.nc", "test", 1, 1);
data1 = read_nc(Float32, "test1.nc", "test", 1, 1);
data2 = read_nc(Float32, "test2.nc", "test", 1, 1);

# read the data at a grid
data = read_nc("test.nc", "test", 1, 1, 1);
data = read_nc(Float32, "test.nc", "test", 1, 1, 1);
```

"""
function read_nc end

read_nc(file::String, var_name::String; transform::Bool = true) = (
    _dset = Dataset(file, "r");

    _fvar = find_variable(_dset, var_name);
    if _fvar === nothing
        close(_dset)
        @error "$(var_name) does not exist in $(file)!";
    end;

    if transform
        _dvar = _fvar[:,:];
    else
        _dvar = _fvar.var[:,:];
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(T, file::String, var_name::String; transform::Bool = true) = T.(read_nc(file, var_name; transform = transform));

read_nc(file::String, var_name::String, indz::Int; transform::Bool = true) = (
    _ndim = size_nc(file, var_name)[1];
    @assert _ndim in [1,3] "The dataset must be a 1D or 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = (_ndim == 1 ? _fvar[indz] : _fvar[:,:,indz]);
    else
        _dvar = (_ndim == 1 ? _fvar.var[indz] : _fvar.var[:,:,indz]);
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(T, file::String, var_name::String, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indz; transform = transform));

read_nc(file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = (
    _ndim = size_nc(file, var_name)[1];
    @assert 2 <= _ndim <= 3 "The dataset must be a 2D or 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = (_ndim==2 ? _fvar[indx,indy] : _fvar[indx,indy,:]);
    else
        _dvar = (_ndim==2 ? _fvar.var[indx,indy] : _fvar.var[indx,indy,:]);
    end;
    close(_dset);

    if sum(ismissing.(_dvar)) == 0
        return _dvar
    end;

    return replace(_dvar, missing=>NaN)
);

read_nc(T, file::String, var_name::String, indx::Int, indy::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy; transform = transform));

read_nc(file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = (
    @assert size_nc(file, var_name)[1] == 3 "The dataset must be a 3D array to use this method!";

    _dset = Dataset(file, "r");
    _fvar = find_variable(_dset, var_name);
    if transform
        _dvar = _fvar[indx,indy,indz];
    else
        _dvar = _fvar.var[indx,indy,indz];
    end;
    close(_dset);

    return ismissing(_dvar) ? NaN : _dvar
);

read_nc(T, file::String, var_name::String, indx::Int, indy::Int, indz::Int; transform::Bool = true) = T.(read_nc(file, var_name, indx, indy, indz; transform = transform));
