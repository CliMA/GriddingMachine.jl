module Indexer

using DocStringExtensions: METHODLIST
using NetcdfIO: read_nc, size_nc


# functions to calculate the lat and lon index
"""
    lat_ind(lat::Number; res::Number=1)

Round the latitude and return the index in a matrix, given
- `lat` Latitude
- `res` Resolution in latitude

---
# Examples
```julia
ilat = lat_ind(0.3);
ilat = lat_ind(0.3; res=0.5);
```
"""
function lat_ind(lat::Number; res::Number=1)
    @assert -90 <= lat <= 90;

    return Int(fld(lat + 90, res)) + 1
end


"""
    lon_ind(lon::Number; res::Number=1)

Round the longitude and return the index in a matrix, given
- `lon` Longitude
- `res` Resolution in longitude

---
# Examples
```julia
ilon = lon_ind(90.3);
ilon = lon_ind(90.3; res=0.5);
```
"""
function lon_ind(lon::Number; res::Number=1)
    @assert -180 <= lon <= 180;

    return Int(fld(lon + 180, res)) + 1
end


# read data and std from given NetCDF file
"""
This function reads look-up-table (LUT) for whole dataset or selected pieces. Supported methods are

$(METHODLIST)

"""
function read_LUT end


"""
    read_LUT(fn::String, FT::DataType = Float32)

Read the entire look-up-table from collection, given
- `fn` Path to the target file
- `FT` Float number type, default is Float32

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()));
read_LUT(query_collection(vcmax_collection()), Float64);
```
"""
read_LUT(fn::String, FT::DataType = Float32) = (
    @assert isfile(fn);

    return read_nc(FT, fn, "data"), read_nc(FT, fn, "std")
);


"""
    read_LUT(fn::String, cyc::Int, FT::DataType = Float32)

Read the entire look-up-table from collection, given
- `fn` Path to the target file
- `cyc` Cycle number, such as 8 for data in Augest in 1 `1M` resolution dataset
- `FT` Float number type, default is Float32

---
# Examples
```julia
read_LUT(query_collection(gpp_collection()), 8);
read_LUT(query_collection(gpp_collection()), 8, Float64);
```
"""
read_LUT(fn::String, cyc::Int, FT::DataType = Float32) = (
    @assert isfile(fn);
    @assert size_nc(fn, "data")[1] == 3;

    return read_nc(FT, fn, "data", cyc), read_nc(FT, fn, "std", cyc)
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT::DataType = Float32; interpolation::Bool = false)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `res` Spatial resolution in `°`
- `FT` Float number type, default is Float32
- `interpolation` If true, interpolate the dataset

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5);
read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5, Float64);
read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5, Float64; interpolation=true);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT::DataType = Float32; interpolation::Bool = false) = (
    @assert isfile(fn);

    # if not at interpolation mode
    _ilat = lat_ind(lat; res=res);
    _ilon = lon_ind(lon; res=res);
    _raw_dat = read_nc(FT, fn, "data", _ilon, _ilat);
    _raw_std = read_nc(FT, fn, "std" , _ilon, _ilat);

    if !interpolation
        return _raw_dat, _raw_std
    end;

    # if at interpolation mode
    _nlat = Int(180 / res);
    _nlon = Int(360 / res);

    # locate the south and north lines of the target pixel
    _ilat_s = Int(fld(lat + 90 - res/2, res) + 1);
    _ilat_n = _ilat_s + 1;
    _dlat_s = lat - (_ilat_s - 1 + 1/2) * res + 90;
    _dlat_n = (_ilat_n - 1 + 1/2) * res - 90 - lat;

    _ilat_s = max(_ilat_s, 1);
    _ilat_n = min(_ilat_n, _nlat);

    # locate the west and east lines of the target pixel
    _ilon_w = Int(fld(lon + 180 - res/2, res) + 1);
    _ilon_e = _ilon_w + 1;
    _dlon_w = lon - (_ilon_w - 1 + 1/2) * res + 180;
    _dlon_e = (_ilon_e - 1 + 1/2) * res - 180 - lon;

    if _ilon_w < 1 _ilon_w = _nlon end;
    if _ilon_e > _nlon _ilon_e = 1 end;

    # interpolate the value
    _val_s = _dlon_w ./ res .* read_nc(FT, fn, "data", _ilon_e, _ilat_s) .+ _dlon_e ./ res .* read_nc(FT, fn, "data", _ilon_w, _ilat_s);
    _val_n = _dlon_w ./ res .* read_nc(FT, fn, "data", _ilon_e, _ilat_n) .+ _dlon_e ./ res .* read_nc(FT, fn, "data", _ilon_w, _ilat_n);
    _val_i = _dlat_s ./ res .* _val_n .+ _dlat_n ./ res .* _val_s;

    # use non-interpolated value if the interpolated one is NaN
    if typeof(_val_i) <: Number
        if isnan(_val_i)
            _val_i = _raw_dat;
        end;
    else
        for _i in eachindex(_val_i)
            if isnan(_val_i[_i])
                _val_i[_i] = _raw_dat[_i];
            end;
        end;
    end;

    # interpolate the standard deviation
    _std_s = _dlon_w ./ res .* read_nc(FT, fn, "std", _ilon_e, _ilat_s) .+ _dlon_e ./ res .* read_nc(FT, fn, "std", _ilon_w, _ilat_s);
    _std_n = _dlon_w ./ res .* read_nc(FT, fn, "std", _ilon_e, _ilat_n) .+ _dlon_e ./ res .* read_nc(FT, fn, "std", _ilon_w, _ilat_n);
    _std_i = _dlat_s ./ res .* _std_n .+ _dlat_n ./ res .* _std_s;

    # use non-interpolated value if the interpolated one is NaN
    if typeof(_std_i) <: Number
        if isnan(_std_i)
            _std_i = _raw_std;
        end;
    else
        for _i in eachindex(_std_i)
            if isnan(_std_i[_i])
                _std_i[_i] = _raw_std[_i];
            end;
        end;
    end;

    return _val_i, _std_i
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, FT::DataType = Float32; interpolation::Bool = false)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `FT` Float number type, default is Float32
- `interpolation` If true, interpolate the dataset

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()), 30, 116);
read_LUT(query_collection(vcmax_collection()), 30, 116, Float64);
read_LUT(query_collection(vcmax_collection()), 30, 116, Float64; interpolation=true);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, FT::DataType = Float32; interpolation::Bool = false) = (
    @assert isfile(fn);

    (_,_sizes) = size_nc(fn, "lat");
    _res = 180 / _sizes[1];

    return read_LUT(fn, lat, lon, _res, FT; interpolation=interpolation)
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, res::Number, FT::DataType = Float32; interpolation::Bool = false)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `cyc` Cycle number, such as 8 for data in Augest in 1 `1M` resolution dataset
- `res` Spatial resolution in `°`
- `FT` Float number type, default is Float32
- `interpolation` If true, interpolate the dataset

---
# Examples
```julia
read_LUT(query_collection(gpp_collection()), 30, 116, 8, 0.5);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, 0.5, Float64);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, 0.5, Float64; interpolation=true);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, res::Number, FT::DataType = Float32; interpolation::Bool = false) = (
    @assert isfile(fn);

    # if not at interpolation mode
    _ilat = lat_ind(lat; res=res);
    _ilon = lon_ind(lon; res=res);
    _raw_dat = read_nc(FT, fn, "data", _ilon, _ilat, cyc);
    _raw_std = read_nc(FT, fn, "std" , _ilon, _ilat, cyc);

    if !interpolation
        return _raw_dat, _raw_std
    end;

    # if at interpolation mode
    _nlat = Int(180 / res);
    _nlon = Int(360 / res);

    # locate the south and north lines of the target pixel
    _ilat_s = Int(fld(lat + 90 - res/2, res) + 1);
    _ilat_n = _ilat_s + 1;
    _dlat_s = lat - (_ilat_s - 1 + 1/2) * res + 90;
    _dlat_n = (_ilat_n - 1 + 1/2) * res - 90 - lat;

    _ilat_s = max(_ilat_s, 1);
    _ilat_n = min(_ilat_n, _nlat);

    # locate the west and east lines of the target pixel
    _ilon_w = Int(fld(lon + 180 - res/2, res) + 1);
    _ilon_e = _ilon_w + 1;
    _dlon_w = lon - (_ilon_w - 1 + 1/2) * res + 180;
    _dlon_e = (_ilon_e - 1 + 1/2) * res - 180 - lon;

    if _ilon_w < 1 _ilon_w = _nlon end;
    if _ilon_e > _nlon _ilon_e = 1 end;

    # interpolate the value
    _val_s = _dlon_w ./ res .* read_nc(FT, fn, "data", _ilon_e, _ilat_s, cyc) .+ _dlon_e ./ res .* read_nc(FT, fn, "data", _ilon_w, _ilat_s, cyc);
    _val_n = _dlon_w ./ res .* read_nc(FT, fn, "data", _ilon_e, _ilat_n, cyc) .+ _dlon_e ./ res .* read_nc(FT, fn, "data", _ilon_w, _ilat_n, cyc);
    _val_i = _dlat_s ./ res .* _val_n .+ _dlat_n ./ res .* _val_s;

    # use non-interpolated value if the interpolated one is NaN
    if typeof(_val_i) <: Number
        if isnan(_val_i)
            _val_i = _raw_dat;
        end;
    else
        for _i in eachindex(_val_i)
            if isnan(_val_i[_i])
                _val_i[_i] = _raw_dat[_i];
            end;
        end;
    end;

    # interpolate the standard deviation
    _std_s = _dlon_w ./ res .* read_nc(FT, fn, "std", _ilon_e, _ilat_s, cyc) .+ _dlon_e ./ res .* read_nc(FT, fn, "std", _ilon_w, _ilat_s, cyc);
    _std_n = _dlon_w ./ res .* read_nc(FT, fn, "std", _ilon_e, _ilat_n, cyc) .+ _dlon_e ./ res .* read_nc(FT, fn, "std", _ilon_w, _ilat_n, cyc);
    _std_i = _dlat_s ./ res .* _std_n .+ _dlat_n ./ res .* _std_s;

    # use non-interpolated value if the interpolated one is NaN
    if typeof(_std_i) <: Number
        if isnan(_std_i)
            _std_i = _raw_std;
        end;
    else
        for _i in eachindex(_std_i)
            if isnan(_std_i[_i])
                _std_i[_i] = _raw_std[_i];
            end;
        end;
    end;

    return _val_i, _std_i
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, FT::DataType = Float32; interpolation::Bool = false)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `cyc` Cycle number, such as 8 for data in Augest in 1 `1M` resolution dataset
- `FT` Float number type, default is Float32
- `interpolation` If true, interpolate the dataset

---
# Examples
```julia
read_LUT(query_collection(gpp_collection()), 30, 116, 8);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, Float64);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, Float64; interpolation=true);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, FT::DataType = Float32; interpolation::Bool = false) = (
    @assert isfile(fn);

    (_,_sizes) = size_nc(fn, "lat");
    _res = 180 / _sizes[1];

    return read_LUT(fn, lat, lon, cyc, _res, FT; interpolation=interpolation)
);


end;
