###############################################################################
#
# Read data from abstractized datasets
#
###############################################################################
"""
    read_LUT(data::MeanMonthlyLAI{FT}, lat::FT, lon::FT, month::Int) where {FT<:AbstractFloat}
    read_LUT(data::VPMGPPv20{FT}, lat::FT, lon::FT, ind::Int) where {FT<:AbstractFloat}

Read the LAI from given
- `data` [`MeanMonthlyLAI`](@ref) type struct
- `lat` Latitude
- `lon` Longitude
- `month` Month number from 1 to 12, or String
- `ind` Index of cycle in the year, e.g., 1-46
"""
function read_LUT(
            data::MeanMonthlyLAI{FT},
            lat::FT,
            lon::FT,
            month::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=data.res_lat);
    ind_lon = lon_ind(lon; res=data.res_lon);
    ind_mon = month<8 ? (month+5) : (month-7);

    return data.LAI[ind_lon, ind_lat, ind_mon]
end




function read_LUT(
            data::VPMGPPv20{FT},
            lat::FT,
            lon::FT,
            ind::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=data.res_lat);
    ind_lon = lon_ind(lon; res=data.res_lon);

    return data.GPP[ind_lon, ind_lat, ind]
end
