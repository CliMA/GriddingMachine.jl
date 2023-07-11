#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2022-Jan-28: add general function add_nc_dim! for multiple dispatch
#     2022-Jan-28: add method to add dim information to Dataset using Int
#     2022-Jan-28: add method to add dim information to Dataset using Inf
#     2022-Jan-28: add method to add dim information to file directly
#     2023-Feb-23: migrate from JuliaUtility to Emerald
#     2023-Jul-05: add parameter var_dims to function save_nc! for data in array
#     2023-Jul-11: fixed bug for save_nc! for growable = true
#
#######################################################################################################################################################################################################
"""

    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int)
    add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat)
    add_nc_dim!(file::String, dim_name::String, dim_size::Union{Int, AbstractFloat})

Add dimension information to netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `dim_name` Dimension name
- `dim_size` Integer dimension size (0 for Inf, growable)

---
# Examples
```julia
ds = Dataset("test.nc", "a");
add_nc_dim!(ds, "lat", 180);
add_nc_dim!(ds, "ind", 0);
add_nc_dim!(ds, "idx", Inf);
close(ds);

add_nc_dim!("test.nc", "lon", 360);
add_nc_dim!("test.nc", "idy", Inf);
```

"""
function add_nc_dim! end

add_nc_dim!(ds::Dataset, dim_name::String, dim_size::Int) = (
    # if dim exists already, do nothing
    if dim_name in keys(ds.dim)
        @warn "Dimension $(dim_name) exists already, do nothing...";

        return nothing
    end;

    # if dim does not exist, define the dimension (0 for unlimited)
    ds.dim[dim_name] = (dim_size == 0 ? Inf : dim_size);

    return nothing
);

add_nc_dim!(ds::Dataset, dim_name::String, dim_size::AbstractFloat) = (
    _size = (dim_size == Inf ? 0 : Int(dim_size));
    add_nc_dim!(ds, dim_name, _size);

    return nothing
);

add_nc_dim!(file::String, dim_name::String, dim_size::Union{Int, AbstractFloat}) = (
    _dset = Dataset(file, "a");
    add_nc_dim!(_dset, dim_name, dim_size);
    close(_dset);

    return nothing
);

#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2021-Dec-24: move the function from PkgUtility to NetcdfIO
#     2022-Jan-28: remove the complicated funtion to create var and dim at the same time
#     2022-Jan-28: add method to add data to Dataset
#     2023-Feb-23: migrate from JuliaUtility to Emerald
#
#######################################################################################################################################################################################################
"""

    append_nc!(ds::Dataset, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}
    append_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}

Append data to existing netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `var_name` New variable name to write to
- `var_data` New variable data to write, can be integer, float, and string with N dimens
- `var_attributes` New variable attributes
- `dim_names` Dimension names in the netcdf file
- `compress` Compression level fro NetCDF, default is 4
- `file` Path of the netcdf dataset

---
# Examples
```julia
create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 5]);

dset = Dataset("test.nc", "a");
append_nc!(dset, "str", ["A" for i in 1:18], Dict("longname" => "test strings"), ["lat"]);
append_nc!(dset, "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);
close(dset);

append_nc!("test.nc", "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
append_nc!("test.nc", "d2d", rand(36,18), Dict("longname" => "a 2d dataset"), ["lon", "lat"]);
```

"""
function append_nc! end

append_nc!(ds::Dataset, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N} = (
    # only if variable does not exist create the variable
    @assert !(var_name in keys(ds)) "You can only add new variable to the dataset!";
    @assert length(dim_names) ==  N "Dimension must be match!";
    @assert 0 <= compress <= 9 "Compression rate must be within 0 to 9";

    # if type of variable is string, set deflatelevel to 0
    if T == String
        compress = 0;
    end;

    _ds_var = defVar(ds, var_name, T, dim_names; attrib = var_attributes, deflatelevel = compress);
    _ds_var[:,:] = var_data;

    return nothing
);

append_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N} = (
    _dset = Dataset(file, "a");
    append_nc!(_dset, var_name, var_data, var_attributes, dim_names; compress = compress);
    close(_dset);

    return nothing
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Dec-24: migrate the function from PkgUtility to NetcdfIO
#     2022-Jan-28: remove the complicated funtion to create var and dim at the same time
#     2022-Jan-28: add global attributes to the generated file
#     2023-Feb-23: migrate from JuliaUtility to Emerald
#
#######################################################################################################################################################################################################
"""

    save_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}; var_dims::Vector{String} = ["lon", "lat", "ind"], compress::Int = 4, growable::Bool = false) where {T<:Union{AbstractFloat,Int,String},N}

Save the 1D, 2D, or 3D data as netcdf file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_data` Data to save
- `var_attributes` Variable attributes for the data, such as unit and long name
- `var_dims` Dimension name of each dimension of the variable data
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

Note that this is a wrapper function of create_nc and append_nc:
- If var_data is 1D, the dim is set to ind
- If var_data is 2D, and no var_dims are given, the dims are set to lon and lat
- If var_data is 3D, and no var_dims are given, the dims are set to lon, lat, and ind

#
    save_nc!(file::String, df::DataFrame, var_names::Vector{String}, var_attributes::Vector{Dict{String,String}}; compress::Int = 4, growable::Bool = false)
    save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false)

Save DataFrame to NetCDF, given
- `file` Path to save the data
- `df` DataFrame to save
- `var_names` The label of data in DataFrame to save
- `var_attributes` Variable attributes for the data to save
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

---
# Examples
```julia
# save 1D, 2D, and 3D data
data1 = rand(12) .+ 273.15;
data2 = rand(36,18) .+ 273.15;
data3 = rand(36,18,12) .+ 273.15;

save_nc!("data1.nc", "data1", data1, Dict("description" => "Random temperature", "unit" => "K"));
save_nc!("data2.nc", "data2", data2, Dict("description" => "Random temperature", "unit" => "K"));
save_nc!("data3.nc", "data3", data3, Dict("description" => "Random temperature", "unit" => "K"));

# save DataFrame
df = DataFrame();
df[!,"A"] = rand(5);
df[!,"B"] = rand(5);
df[!,"C"] = rand(5);
save_nc!("dataf.nc", df, ["A","B"], [Dict("A" => "Attribute A"), Dict("B" => "Attribute B")]);

save_nc!("test.nc", df);
```

"""
function save_nc! end


save_nc!(file::String, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}; var_dims::Vector{String} = ["lon", "lat", "ind"], compress::Int = 4, growable::Bool = false) where {T<:Union{AbstractFloat,Int,String},N} = (
    @assert 1 <= N <= 3 "Variable must be a 1D, 2D, or 3D dataset!";
    @assert 0 <= compress <= 9 "Compression rate must be within 0 to 9";

    # create the file
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    # the case if the dimension is 1D
    if N==1
        _n_ind = (growable ? Inf : length(var_data));
        _inds  = collect(eachindex(var_data));
        add_nc_dim!(_dset, "ind", _n_ind);
        append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
        append_nc!(_dset, var_name, var_data, var_attributes, ["ind"]; compress=compress);

        close(_dset);

        return nothing
    end;

    # if the dimension is 2D or 3D

    _lon = 0;
    _lat = 0;
    _ind = 0;
    for i in range(1, length(var_dims))
        if var_dims[i] == "lon" _lon = i; end
        if var_dims[i] == "lat" _lat = i; end
        if var_dims[i] == "ind" _ind = i; end
    end;

    @assert _lon > 0 && _lat > 0 "Two of the dimensions must be named lon and lat (and ind for third dimension if there is one)";

    _n_lon   = size(var_data, _lon);
    _n_lat   = size(var_data, _lat);
    _res_lon = 360 / _n_lon;
    _res_lat = 180 / _n_lat;
    _lons    = collect(_res_lon/2:_res_lon:360) .- 180;
    _lats    = collect(_res_lat/2:_res_lat:180) .- 90;
    add_nc_dim!(_dset, "lon", _n_lon);
    add_nc_dim!(_dset, "lat", _n_lat);
    append_nc!(_dset, "lon", _lons, ATTR_LON, ["lon"]; compress=compress);
    append_nc!(_dset, "lat", _lats, ATTR_LAT, ["lat"]; compress=compress);

    if N==2
        append_nc!(_dset, var_name, var_data, var_attributes, var_dims; compress=compress);
    elseif N==3
        _n_ind = (growable ? Inf : size(var_data, _ind));
        _inds  = collect(1:_n_ind);
        add_nc_dim!(_dset, "ind", _n_ind);
        append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
        append_nc!(_dset, var_name, var_data, var_attributes, var_dims; compress=compress);
    end;

    close(_dset);

    return nothing
);

save_nc!(file::String, df::DataFrame, var_names::Vector{String}, var_attributes::Vector{Dict{String,String}}; compress::Int = 4, growable::Bool = false) = (
    @assert 0 <= compress <= 9 "Compression rate must be within 0 to 9";
    @assert length(var_names) == length(var_attributes) "Variable name and attributes lengths must match!";

    # create the file
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    # define dimension related variables
    _n_ind = (growable ? Inf : size(df)[1]);
    _inds  = collect(1:size(df)[1]);

    # save the variables
    add_nc_dim!(_dset, "ind", _n_ind);
    append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
    for _i in eachindex(var_names)
        append_nc!(_dset, var_names[_i], df[:, var_names[_i]], var_attributes[_i], ["ind"]; compress = compress);
    end;

    close(_dset);

    return nothing
);

save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false) = (
    _var_names = names(df);
    _var_attrs = [Dict{String,String}(_vn => _vn) for _vn in _var_names];

    save_nc!(file, df, _var_names, _var_attrs; compress=compress, growable = growable);

    return nothing
);