"""

    lat_ind(lat::Number, res::Number)

Compute the latitude index from -90 to 90 degrees, given
- `lat`: latitude in degrees
- `res`: resolution in degrees (per grid)

"""
function lat_ind(lat::Number, res::Number)
    @assert -90 <= lat <= 90;

    return Int(fld(lat + 90, res)) + 1
end;


"""

    lon_ind(lon::Number, res::Number)

Compute the longitude index from -180 to 180 degrees, given
- `lon`: longitude in degrees (if >180, it will be converted to -180 to 180)
- `res`: resolution in degrees (per grid)

"""
function lon_ind(lon::Number, res::Number)
    newlon = if lon > 180
        @warn "Longitude exceeds 180°, subtracting 360° to make it within -180° to 180° range";
        lon - 360
    else
        lon
    end;
    @assert -180 <= newlon <= 180;

    return Int(fld(newlon + 180, res)) + 1
end;
