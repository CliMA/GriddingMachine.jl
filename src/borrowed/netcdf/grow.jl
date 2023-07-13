#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2022-Jan-27: define the function to grow a netcdf file
#     2022-Jan-28: add the function to grow semi-automatically with respect to data dimensions
#     2023-Feb-23: migrate from JuliaUtility to Emerald
#     2023-Jul-06: add method to grow dataframe type dataset
#     2023-Jul-13: remove @show
#
#######################################################################################################################################################################################################
"""

    grow_nc!(ds::Dataset, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool)
    grow_nc!(file::String, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool)

Grow the netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `var_name` New variable name to write to
- `in_data` New data to grow, can be integer, float, and string with N dimens
- `pending` If true, the new data is appened to the end (growth); if false, the data will replace the ones from the bottom (when dimension has already growed)
- `file` Path of the netcdf dataset

Note that if there are more variables to grow at the same time, set `pending` to `true` only for the first time you call this function, and set `pending` to `false` for the rest variables.

---
# Examples
```julia
create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 0]);
dset = Dataset("test.nc", "a");
append_nc!(dset, "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
append_nc!(dset, "lon", collect(1:36), Dict("longname" => "longitude"), ["lon"]; compress=4);
append_nc!(dset, "ind", collect(1:5), Dict("longname" => "index"), ["ind"]);
append_nc!(dset, "d2d", rand(36,18), Dict("longname" => "a 2d dataset"), ["lon", "lat"]);
append_nc!(dset, "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);
grow_nc!(dset, "ind", 6, true);
grow_nc!(dset, "d3d", rand(36,18), false);
grow_nc!(dset, "d3d", rand(36,18), true);
grow_nc!(dset, "ind", 7, false);
close(dset);

grow_nc!("test.nc", "ind", 8, true);
grow_nc!("test.nc", "d3d", rand(36,18), false);
grow_nc!("test.nc", "d3d", rand(36,18), true);
grow_nc!("test.nc", "ind", 9, false);
```

"""
function grow_nc! end

grow_nc!(ds::Dataset, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool) = (
    # make sure the data to grow has -1 or the same dimensions as the target, e.g., a 3D dataset can grow with 2D or 3D input
    _dim_ds = length(size(ds[var_name]));
    _dim_in = length(size(in_data));
    @assert _dim_in in [_dim_ds, _dim_ds - 1] "Data to grow must have same or -1 dimensions compared to data in the netcdf file!";
    @assert _dim_ds <= 3 "This function only supports 1D to 3D datasets!";

    # calculate how many layers to add
    if _dim_in < _dim_ds
        _n = 1;
    else
        _n = (typeof(in_data) <: Array ? size(in_data)[end] : 1);
    end;

    # if the data need to pend to the end (grow in unlimited dimension)
    if pending
        if _dim_ds == 1
            ds[var_name][end+1:end+_n] = in_data;
        elseif _dim_ds == 2
            ds[var_name][:,end+1:end+_n] = in_data;
        elseif _dim_ds == 3
            ds[var_name][:,:,end+1:end+_n] = in_data;
        end;
    end;

    # if the unlimited dimension has grown already
    if !pending
        if _dim_ds == 1
            ds[var_name][end+1-_n:end] = in_data;
        elseif _dim_ds == 2
            ds[var_name][:,end+1-_n:end] = in_data;
        elseif _dim_ds == 3
            ds[var_name][:,:,end+1-_n:end] = in_data;
        end;
    end;

    return nothing
);

grow_nc!(file::String, var_name::String, in_data::Union{AbstractFloat,Array,Int,String}, pending::Bool) = (
    _dset = Dataset(file, "a");
    grow_nc!(_dset, var_name, in_data, pending);
    close(_dset);

    return nothing
);

grow_nc!(ds::Dataset, df::DataFrame) = (
    _dim_ind = size_nc(ds, "ind");
    grow_nc!(ds, "ind", collect(axes(df,1) .+ _dim_ind[2][1]), true);
    
    for _var in names(df)
        grow_nc!(ds, _var, df[:,_var], false);
    end;

    return nothing
);

grow_nc!(file::String, in_data::DataFrame) = (
    _dset = Dataset(file, "a");
    grow_nc!(_dset, in_data);
    close(_dset);

    return nothing
);
