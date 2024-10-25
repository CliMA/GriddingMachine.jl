module Indexer

using NetcdfIO: read_nc, size_nc

export read_LUT


#######################################################################################################################################################################################################
#
# Changes to the function
#
#######################################################################################################################################################################################################
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


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: If lon exceeds 180, subtract 360 to make it within -180 to 180 range
#
#######################################################################################################################################################################################################
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
    newlon = if lon > 180
        @warn "Longitude exceeds 180°, subtracting 360° to make it within -180° to 180° range";
        lon - 360
    else
        lon
    end;
    @assert -180 <= newlon <= 180;

    return Int(fld(newlon + 180, res)) + 1
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: Add include_std option
#     2024-Oct-25: Make include_std option does not call variables within a if statement
#
#######################################################################################################################################################################################################
"""

    read_LUT(fn::String, FT::DataType = Float32; include_std::Bool = true)
    read_LUT(fn::String, cyc::Int, FT::DataType = Float32; include_std::Bool = true)
    read_LUT(fn::String, lat::Number, lon::Number, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false)
    read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false)

Read the entire look-up-table from collection, given
- `fn` Path to the target file
- `FT` Float number type, default is Float32
- `include_std` If true, read the standard deviation as well (default is true)
- `cyc` Cycle number, such as 8 for data in Augest in 1 `1M` resolution dataset
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `res` Spatial resolution in `°`
- `interpolation` If true, interpolate the dataset

---
# Examples
```julia
read_LUT(query_collection(vcmax_collection()));
read_LUT(query_collection(vcmax_collection()), Float64);
read_LUT(query_collection(gpp_collection()), 8);
read_LUT(query_collection(gpp_collection()), 8, Float64);
read_LUT(query_collection(gpp_collection()), 30, 116);
read_LUT(query_collection(gpp_collection()), 30, 116, Float64);
read_LUT(query_collection(gpp_collection()), 30, 116, Float64; interpolation=true);
read_LUT(query_collection(gpp_collection()), 30, 116, 8);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, Float64);
read_LUT(query_collection(gpp_collection()), 30, 116, 8, Float64; interpolation=true);
```

"""
function read_LUT end

read_LUT(fn::String, FT::DataType = Float32; include_std::Bool = true) = (
    @assert isfile(fn);

    if include_std
        return read_nc(FT, fn, "data"), read_nc(FT, fn, "std")
    else
        return read_nc(FT, fn, "data")
    end;
);

read_LUT(fn::String, cyc::Int, FT::DataType = Float32; include_std::Bool = true) = (
    @assert isfile(fn);
    @assert size_nc(fn, "data")[1] == 3;

    if include_std
        return read_nc(FT, fn, "data", cyc), read_nc(FT, fn, "std", cyc)
    else
        return read_nc(FT, fn, "data", cyc)
    end;
);

read_LUT(fn::String, lat::Number, lon::Number, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false) = (
    @assert isfile(fn);

    (_,sizes) = size_nc(fn, "lat");
    res = 180 / sizes[1];

    return read_LUT(fn, lat, lon, res, FT; include_std = include_std, interpolation = interpolation)
);

read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false) = (
    @assert isfile(fn);

    # if not at interpolation mode
    ilat = lat_ind(lat; res = res);
    ilon = lon_ind(lon; res = res);
    raw_dat = read_nc(FT, fn, "data", ilon, ilat);
    raw_std = include_std ? read_nc(FT, fn, "std" , ilon, ilat) : nothing;

    # if not at interpolation mode
    if !interpolation
        return include_std ? (raw_dat, raw_std) : raw_dat
    end;

    # if at interpolation mode
    nlat = Int(180 / res);
    nlon = Int(360 / res);

    # locate the south and north lines of the target pixel
    ilat_s = Int(fld(lat + 90 - res/2, res) + 1);
    ilat_n = ilat_s + 1;
    dlat_s = lat - (ilat_s - 1 + 1/2) * res + 90;
    dlat_n = (ilat_n - 1 + 1/2) * res - 90 - lat;

    ilat_s = max(ilat_s, 1);
    ilat_n = min(ilat_n, nlat);

    # locate the west and east lines of the target pixel
    ilon_w = Int(fld(lon + 180 - res/2, res) + 1);
    ilon_e = ilon_w + 1;
    dlon_w = lon - (ilon_w - 1 + 1/2) * res + 180;
    dlon_e = (ilon_e - 1 + 1/2) * res - 180 - lon;

    if ilon_w < 1 ilon_w = nlon end;
    if ilon_e > nlon ilon_e = 1 end;

    # interpolate the value
    val_s = dlon_w ./ res .* read_nc(FT, fn, "data", ilon_e, ilat_s) .+ dlon_e ./ res .* read_nc(FT, fn, "data", ilon_w, ilat_s);
    val_n = dlon_w ./ res .* read_nc(FT, fn, "data", ilon_e, ilat_n) .+ dlon_e ./ res .* read_nc(FT, fn, "data", ilon_w, ilat_n);
    val_i = dlat_s ./ res .* val_n .+ dlat_n ./ res .* val_s;

    # use non-interpolated value if the interpolated one is NaN
    if typeof(val_i) <: Number
        if isnan(val_i)
            val_i = raw_dat;
        end;
    else
        for i in eachindex(val_i)
            if isnan(val_i[i])
                val_i[i] = raw_dat[i];
            end;
        end;
    end;

    # interpolate the standard deviation
    std_i = similar(val_i);
    if include_std
        std_s = dlon_w ./ res .* read_nc(FT, fn, "std", ilon_e, ilat_s) .+ dlon_e ./ res .* read_nc(FT, fn, "std", ilon_w, ilat_s);
        std_n = dlon_w ./ res .* read_nc(FT, fn, "std", ilon_e, ilat_n) .+ dlon_e ./ res .* read_nc(FT, fn, "std", ilon_w, ilat_n);
        std_i = dlat_s ./ res .* std_n .+ dlat_n ./ res .* std_s;

        # use non-interpolated value if the interpolated one is NaN
        if typeof(std_i) <: Number
            if isnan(std_i)
                std_i = raw_std;
            end;
        else
            for i in eachindex(std_i)
                if isnan(std_i[i])
                    std_i[i] = raw_std[i];
                end;
            end;
        end;
    end;

    return include_std ? (val_i, std_i) : val_i
);

read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false) = (
    @assert isfile(fn);

    (_,sizes) = size_nc(fn, "lat");
    res = 180 / sizes[1];

    return read_LUT(fn, lat, lon, cyc, res, FT; include_std = include_std, interpolation=interpolation)
);

read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, res::Number, FT::DataType = Float32; include_std::Bool = true, interpolation::Bool = false) = (
    @assert isfile(fn);

    # if not at interpolation mode
    ilat = lat_ind(lat; res=res);
    ilon = lon_ind(lon; res=res);
    raw_dat = read_nc(FT, fn, "data", ilon, ilat, cyc);
    raw_std = include_std ? read_nc(FT, fn, "std" , ilon, ilat, cyc) : nothing;

    if !interpolation
        return include_std ? (raw_dat, raw_std) : raw_dat
    end;

    # if at interpolation mode
    nlat = Int(180 / res);
    nlon = Int(360 / res);

    # locate the south and north lines of the target pixel
    ilat_s = Int(fld(lat + 90 - res/2, res) + 1);
    ilat_n = ilat_s + 1;
    dlat_s = lat - (ilat_s - 1 + 1/2) * res + 90;
    dlat_n = (ilat_n - 1 + 1/2) * res - 90 - lat;

    ilat_s = max(ilat_s, 1);
    ilat_n = min(ilat_n, nlat);

    # locate the west and east lines of the target pixel
    ilon_w = Int(fld(lon + 180 - res/2, res) + 1);
    ilon_e = ilon_w + 1;
    dlon_w = lon - (ilon_w - 1 + 1/2) * res + 180;
    dlon_e = (ilon_e - 1 + 1/2) * res - 180 - lon;

    if ilon_w < 1 ilon_w = nlon end;
    if ilon_e > nlon ilon_e = 1 end;

    # interpolate the value
    val_s = dlon_w / res * read_nc(FT, fn, "data", ilon_e, ilat_s, cyc) + dlon_e / res * read_nc(FT, fn, "data", ilon_w, ilat_s, cyc);
    val_n = dlon_w / res * read_nc(FT, fn, "data", ilon_e, ilat_n, cyc) + dlon_e / res * read_nc(FT, fn, "data", ilon_w, ilat_n, cyc);
    val_i = dlat_s / res * val_n + dlat_n / res * val_s;

    # use non-interpolated value if the interpolated one is NaN
    if isnan(val_i)
        val_i = raw_dat;
    end;

    # interpolate the standard deviation
    std_s = dlon_w / res * read_nc(FT, fn, "std", ilon_e, ilat_s, cyc) + dlon_e / res * read_nc(FT, fn, "std", ilon_w, ilat_s, cyc);
    std_n = dlon_w / res * read_nc(FT, fn, "std", ilon_e, ilat_n, cyc) + dlon_e / res * read_nc(FT, fn, "std", ilon_w, ilat_n, cyc);
    std_i = dlat_s / res * std_n + dlat_n / res * std_s;

    # use non-interpolated value if the interpolated one is NaN
    if isnan(std_i)
        std_i = raw_std;
    end;

    return include_std ? (val_i, std_i) : val_i
);


end; # module
