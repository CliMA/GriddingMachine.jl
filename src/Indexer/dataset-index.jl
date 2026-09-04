"""Return the 1-based latitude-cell index for a regular global grid."""
function lat_ind(lat::Number, res::Number)
    @assert -90 <= lat <= 90
    @assert res > 0 && 180 / res >= 1
    n_lat = round(Int, 180 / res)
    return clamp(Int(fld(lat + 90, res)) + 1, 1, n_lat)
end

"""Return the 1-based longitude-cell index, wrapping longitudes outside `[-180, 180]`."""
function lon_ind(lon::Number, res::Number)
    @assert res > 0 && 360 / res >= 1
    newlon = if -180 <= lon <= 180
        lon
    else
        @warn "Longitude is outside [-180, 180] degrees; wrapping it to this interval"
        mod(lon + 180, 360) - 180
    end
    n_lon = round(Int, 360 / res)
    return clamp(Int(fld(newlon + 180, res)) + 1, 1, n_lon)
end
