###############################################################################
#
# Read data from abstractized dataset
#
###############################################################################
"""
    read_LUT(
                dataset::MeanMonthlyLAI{FT},
                lat::FT,
                lon::FT,
                month::Int
    ) where {FT<:AbstractFloat}

Read the LAI from given
- `dataset` [`MeanMonthlyLAI`](@ref) type struct
- `lat` Latitude
- `lon` Longitude
- `month` Month number from 1 to 12, or String
"""
function read_LUT(
            dataset::MeanMonthlyLAI{FT},
            lat::FT,
            lon::FT,
            month::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=dataset.res_lat);
    ind_lon = lon_ind(lon; res=dataset.res_lon);
    ind_mon = month<8 ? (month+5) : (month-7);

    return dataset.LAI[ind_lon, ind_lat, ind_mon]
end
