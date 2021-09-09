module Indexer

using DocStringExtensions: METHODLIST
using PkgUtility: read_nc


# export public functions
export lat_ind, lon_ind


# functions to calculate the lat and lon index
"""
    lat_ind(lat::Number; res::Number=1)

Round the latitude and return the index in a matrix, given
- `lat` Latitude
- `res` Resolution in latitude

---
# Examples
```julia
ilat = lat_ind(90.3);
ilat = lat_ind(90.3; res=0.5);
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
    @assert -180 <= lon <= 360;

    if lon <=180
        return Int(fld(lon + 180, res)) + 1
    else
        return Int(fld(lon - 180, res)) + 1
    end
end


# read data and std from given NetCDF file
"""
This function reads look-up-table (LUT) for whole dataset or selected pieces. Supported methods are

$(METHODLIST)

"""
function read_LUT end


"""
    read_LUT(fn::String, FT = Float32)

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
read_LUT(fn::String, FT = Float32) = (
    @assert isfile(fn);

    return read_nc(FT, fn, "data"), read_nc(FT, fn, "std")
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT=Float32)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `res` Spatial resolution in `°`
- `FT` Float number type, default is Float32

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5);
read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5, Float64);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT=Float32) = (
    @assert isfile(fn);

    _ilat = lat_ind(lat; res=res);
    _ilon = lon_ind(lon; res=res);

    return read_nc(FT, fn, "data", _ilon, _ilat), read_nc(FT, fn, "std", _ilon, _ilat)
);


"""
    read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT=Float32)

Read the selected part of a look-up-table from collection, given
- `fn` Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `FT` Float number type, default is Float32

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()), 30, 116);
read_LUT(query_collection(vcmax_collection()), 30, 116, Float64);
```
"""
read_LUT(fn::String, lat::Number, lon::Number, FT=Float32) = (
    @assert isfile(fn);

    _lats = read_nc(FT, fn, "lat");
    _res  = _lats[2] - _lats[1];

    return read_LUT(fn, lat, lon, _res, FT)
);


end