###############################################################################
#
# Read data from abstractized datasets
#
###############################################################################
"""
    read_LUT(ds::GriddedDataset{FT}, lat::FT, lon::FT) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT}, lat::FT, lon::FT, ind::Int) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT}, data_type::AbstractDataset{FT}, lat::FT, lon::FT) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT}, data_type::AbstractDataset{FT}, lat::FT, lon::FT, ind::Int) where {FT<:AbstractFloat}

Read the LAI from given
- `ds` [`LAIMonthlyMean`](@ref) type struct
- `data_type` Dataset type, subtype of [`AbstractDataset`](@ref)
- `lat` Latitude
- `lon` Longitude
- `ind` Index of cycle in the year, e.g., 1-46, or Month number from 1 to 12
    for LAIMonthlyMean DataType
"""
function read_LUT(
            ds::GriddedDataset{FT},
            lat::FT,
            lon::FT
) where {FT<:AbstractFloat}
    return read_LUT(ds, ds.data_type, lat, lon)
end




function read_LUT(
            ds::GriddedDataset{FT},
            lat::FT,
            lon::FT,
            ind::Int
) where {FT<:AbstractFloat}
    return read_LUT(ds, ds.data_type, lat, lon, ind)
end




function read_LUT(
            ds::GriddedDataset{FT},
            data_type::LAIMonthlyMean{FT},
            lat::FT,
            lon::FT,
            ind::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=ds.res_lat);
    ind_lon = lon_ind(lon; res=ds.res_lon);
    ind_mon = ind<8 ? (ind+5) : (ind-7);

    return ds.data[ind_lon, ind_lat, ind_mon]
end




function read_LUT(
            ds::GriddedDataset{FT},
            data_type::AbstractDataset{FT},
            lat::FT,
            lon::FT
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=ds.res_lat);
    ind_lon = lon_ind(lon; res=ds.res_lon);

    return ds.data[ind_lon, ind_lat, 1]
end




function read_LUT(
            ds::GriddedDataset{FT},
            data_type::AbstractDataset{FT},
            lat::FT,
            lon::FT,
            ind::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=ds.res_lat);
    ind_lon = lon_ind(lon; res=ds.res_lon);

    return ds.data[ind_lon, ind_lat, ind]
end
