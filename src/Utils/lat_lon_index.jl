###############################################################################
#
# Determine the latitude and longitude index in matrix
#
###############################################################################
"""
    lat_ind(lat::FT; res::FT) where {FT<:AbstractFloat}

Round the latitude and return the index in a matrix, Given
- `lat` Latitude
- `res` Resolution in latitude
"""
function lat_ind(lat::FT; res::FT=FT(1)) where {FT<:AbstractFloat}
    # judge if lat is within -90 to 90
    if -90 <= lat <= 90
        return Int(fld(lat + 90, res)) + 1
    else
        return ErrorException("Given latitude is out of [-90,90]")
    end
end




"""
    lon_ind(lon::FT; res::FT=1) where {FT<:AbstractFloat}

Round the longitude and return the index in a matrix, Given
- `lon` Longitude
- `res` Resolution in longitude
"""
function lon_ind(lon::FT; res::FT=FT(1)) where {FT<:AbstractFloat}
    # judge if lat is within -90 to 90
    if -180 <= lon <= 180
        return Int(fld(lon + 180, res)) + 1
    elseif 180 < lon <= 360
        return Int(fld(lon - 180, res)) + 1
    else
        return ErrorException("Given longitude is out of [-180,360]")
    end
end
