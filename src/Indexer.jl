module Indexer

using NetcdfIO: read_nc, size_nc, varname_nc

using ..Collector: download_artifact!


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2021-Sep-09: add function to get the index of latitude
#
#######################################################################################################################################################################################################
"""

    lat_ind(lat::Number; res::Number = 1)

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
function lat_ind(lat::Number; res::Number = 1)
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

    lon_ind(lon::Number; res::Number = 1)

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
function lon_ind(lon::Number; res::Number = 1)
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
#     2024-Oct-28: Add an option to allow for the case of no "std" variable in the file (was forcing NaN before, which is not necessary)
#     2024-Oct-28: Allow fn to be tag name or path to the file (was only allowing path to the file before)
#
#######################################################################################################################################################################################################
"""

    read_LUT(fn::String; include_std::Bool = true)
    read_LUT(fn::String, cyc::Int; include_std::Bool = true)
    read_LUT(fn::String, lat::Number, lon::Number; include_std::Bool = true, interpolation::Bool = false)
    read_LUT(fn::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true, interpolation::Bool = false)
    read_LUT(fn::String, lats::Vector, lons::Vector; include_std::Bool = true)

Read the entire look-up-table from collection, given
- `fn` Tag name or Path to the target file
- `lat` Latitude in `°`
- `lon` Longitude in `°`
- `cyc` Cycle number, such as 8 for data in Augest in 1 `1M` resolution dataset
- `include_std` If true, read the standard deviation as well (default is true)
- `interpolation` If true, interpolate the dataset
- `lats` Latitude range (a vector of two elements)
- `lons` Longitude range (a vector of two elements)

---
# Examples
```julia
Indexer.read_LUT("CI_2X_1Y_V1");
Indexer.read_LUT("CI_2X_1M_V3");
Indexer.read_LUT("CI_2X_1M_V3", 8);
Indexer.read_LUT("CI_2X_1M_V3", 30, 116);
Indexer.read_LUT("CI_2X_1M_V3", 30, 116; interpolation = true);
Indexer.read_LUT("CI_2X_1M_V3", 30, 116, 8);
Indexer.read_LUT("REFLECTANCE_MCD43A4_B1_1X_1M_2000_V1", 30, 116, 8);
Indexer.read_LUT("CI_240X_1Y_V1", [-10,10], [-10,10]);
Indexer.read_LUT("CI_2X_1M_V3", [-10,10], [-10,10]; include_std = false);
```

"""
function read_LUT end;

read_LUT(fn::String; include_std::Bool = true) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);

    # if include_std is false
    if !include_std
        return read_nc(fpath, "data")
    end;

    # if include_std is true, but the file does not have std variable
    if !("std" in varname_nc(fpath))
        return read_nc(fpath, "data"), nothing
    end;

    # if include_std is true, and the file has std variable
    return read_nc(fpath, "data"), read_nc(fpath, "std")
);


read_LUT(fn::String, cyc::Int; include_std::Bool = true) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);
    @assert size_nc(fpath, "data")[1] == 3;

    # if include_std is false
    if !include_std
        return read_nc(fpath, "data", cyc)
    end;

    # if include_std is true, but the file does not have std variable
    if !("std" in varname_nc(fpath))
        return read_nc(fpath, "data", cyc), nothing
    end;

    # if include_std is true, and the file has std variable
    return read_nc(fpath, "data", cyc), read_nc(fpath, "std", cyc)
);

read_LUT(fn::String, lats::Vector, lons::Vector; include_std::Bool = true) = (
    # make sure the lats and lons are within the range
    @assert -90 <= lats[1] < lats[2] <= 90 "Latitude range is not valid";
    @assert -180 <= lons[1] < lons[2] <= 180 "Longitude range is not valid";

    # dertermine the resolution
    fpath = isfile(fn) ? fn : download_artifact!(fn);
    (_,sizes) = size_nc(fpath, "data");
    res_lon = 360 / sizes[1];
    res_lat = 180 / sizes[2];

    # determine the indices
    ilons = [lon_ind(lon; res = res_lon) for lon in lons];
    ilats = [lat_ind(lat; res = res_lat) for lat in lats];
    ind_lon = ilons[1]:ilons[2];
    ind_lat = ilats[1]:ilats[2];

    # read the actual lat/lon
    vec_lat = read_nc(fpath, "lat", [ind_lat]);
    vec_lon = read_nc(fpath, "lon", [ind_lon]);

    # if include_std is false
    if !include_std
        return if length(sizes) < 3
            vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat])
        else
            vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat,:])
        end;
    end;

    # if include_std is true, but the file does not have std variable
    if !("std" in varname_nc(fpath))
        return if length(sizes) < 3
            vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat]), nothing
        else
            vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat,:]), nothing
        end;
    end;

    # if include_std is true, and the file has std variable
    return if length(sizes) < 3
        vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat]), read_nc(fpath, "std", [ind_lon,ind_lat])
    else
        vec_lon, vec_lat, read_nc(fpath, "data", [ind_lon,ind_lat,:]), read_nc(fpath, "std", [ind_lon,ind_lat,:])
    end;
);

read_LUT(fn::String, lat::Number, lon::Number; include_std::Bool = true, interpolation::Bool = false) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);

    (_,sizes) = size_nc(fpath, "lat");
    res = 180 / sizes[1];

    return read_LUT(fpath, lat, lon, res; include_std = include_std, interpolation = interpolation)
);

read_LUT(fn::String, lat::Number, lon::Number, res::Number; include_std::Bool = true, interpolation::Bool = false) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);

    # if not at interpolation mode
    ilat = lat_ind(lat; res = res);
    ilon = lon_ind(lon; res = res);
    raw_dat = read_nc(fpath, "data", ilon, ilat);
    raw_std = include_std ? ("std" in varname_nc(fpath) ? read_nc(fpath, "std" , ilon, ilat) : nothing) : nothing;

    # if not at interpolation mode
    if !interpolation
        return include_std ? (raw_dat, raw_std) : raw_dat
    end;

    # if at interpolation mode
    nlat = Int(180 / res);
    nlon = Int(360 / res);

    # locate the south and north edges of the target pixel
    ilat_s = Int(fld(lat + 90 - res/2, res) + 1);
    ilat_n = ilat_s + 1;
    dlat_s = lat - (ilat_s - 1 + 1/2) * res + 90;
    dlat_n = (ilat_n - 1 + 1/2) * res - 90 - lat;

    ilat_s = max(ilat_s, 1);
    ilat_n = min(ilat_n, nlat);

    # locate the west and east edges of the target pixel
    ilon_w = Int(fld(lon + 180 - res/2, res) + 1);
    ilon_e = ilon_w + 1;
    dlon_w = lon - (ilon_w - 1 + 1/2) * res + 180;
    dlon_e = (ilon_e - 1 + 1/2) * res - 180 - lon;

    if ilon_w < 1 ilon_w = nlon end;
    if ilon_e > nlon ilon_e = 1 end;

    # interpolate the value
    val_s = dlon_w ./ res .* read_nc(fpath, "data", ilon_e, ilat_s) .+ dlon_e ./ res .* read_nc(fpath, "data", ilon_w, ilat_s);
    val_n = dlon_w ./ res .* read_nc(fpath, "data", ilon_e, ilat_n) .+ dlon_e ./ res .* read_nc(fpath, "data", ilon_w, ilat_n);
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
    std_i = nothing;
    if include_std && ("std" in varname_nc(fpath))
        std_s = dlon_w ./ res .* read_nc(fpath, "std", ilon_e, ilat_s) .+ dlon_e ./ res .* read_nc(fpath, "std", ilon_w, ilat_s);
        std_n = dlon_w ./ res .* read_nc(fpath, "std", ilon_e, ilat_n) .+ dlon_e ./ res .* read_nc(fpath, "std", ilon_w, ilat_n);
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

read_LUT(fn::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true, interpolation::Bool = false) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);

    (_,sizes) = size_nc(fpath, "lat");
    res = 180 / sizes[1];

    return read_LUT(fpath, lat, lon, cyc, res; include_std = include_std, interpolation = interpolation)
);

read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, res::Number; include_std::Bool = true, interpolation::Bool = false) = (
    fpath = isfile(fn) ? fn : download_artifact!(fn);

    # if not at interpolation mode
    ilat = lat_ind(lat; res=res);
    ilon = lon_ind(lon; res=res);
    raw_dat = read_nc(fpath, "data", ilon, ilat, cyc);
    raw_std = include_std ? ("std" in varname_nc(fpath) ? read_nc(fpath, "std" , ilon, ilat, cyc) : nothing) : nothing;

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
    val_s = dlon_w / res * read_nc(fpath, "data", ilon_e, ilat_s, cyc) + dlon_e / res * read_nc(fpath, "data", ilon_w, ilat_s, cyc);
    val_n = dlon_w / res * read_nc(fpath, "data", ilon_e, ilat_n, cyc) + dlon_e / res * read_nc(fpath, "data", ilon_w, ilat_n, cyc);
    val_i = dlat_s / res * val_n + dlat_n / res * val_s;

    # use non-interpolated value if the interpolated one is NaN
    if isnan(val_i)
        val_i = raw_dat;
    end;

    # interpolate the standard deviation
    std_i = nothing;
    if include_std && ("std" in varname_nc(fpath))
        std_s = dlon_w / res * read_nc(fpath, "std", ilon_e, ilat_s, cyc) + dlon_e / res * read_nc(fpath, "std", ilon_w, ilat_s, cyc);
        std_n = dlon_w / res * read_nc(fpath, "std", ilon_e, ilat_n, cyc) + dlon_e / res * read_nc(fpath, "std", ilon_w, ilat_n, cyc);
        std_i = dlat_s / res * std_n + dlat_n / res * std_s;

        # use non-interpolated value if the interpolated one is NaN
        if isnan(std_i)
            std_i = raw_std;
        end;
    end;

    return include_std ? (val_i, std_i) : val_i
);


end; # module
