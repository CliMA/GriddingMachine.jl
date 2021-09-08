###############################################################################
#
# Read data from abstractized datasets
#
###############################################################################
"""
    read_LUT(ds::GriddedDataset{FT},
             lat::FT,
             lon::FT,
             ind::Int) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT},
             dt::AbstractDataset{FT},
             lat::FT,
             lon::FT,
             ind::Int) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT},
             lat::Tuple{FT,FT},
             lon::Tuple{FT,FT},
             ind::Tuple{Int,Int}) where {FT<:AbstractFloat}
    read_LUT(ds::GriddedDataset{FT},
             dt::AbstractDataset{FT},
             lat::Tuple{FT,FT},
             lon::Tuple{FT,FT},
             ind::Tuple{Int,Int}) where {FT<:AbstractFloat}

Read the dataset from given
- `ds` [`GriddedDataset`](@ref) type struct
- `dt` Dataset type, subtype of [`AbstractDataset`](@ref)
- `lat` Latitude
- `lon` Longitude
- `ind` Index of cycle in the year, e.g., 1-46, or Month number from 1 to 12
    for LAIMonthlyMean DataType
"""
function read_LUT(
            ds::GriddedDataset{FT},
            lat::FT,
            lon::FT,
            ind::Int = 1
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=ds.res_lat);
    ind_lon = lon_ind(lon; res=ds.res_lon);

    return ds.data[ind_lon, ind_lat, ind]
end




function read_LUT(
            ds::GriddedDataset{FT},
            lats::Tuple{FT,FT},
            lons::Tuple{FT,FT},
            inds::Tuple{Int,Int} = (1,1)
) where {FT<:AbstractFloat}
    _lat1, _lat2 = lats;
    _lon1, _lon2 = lons;
    _ind1, _ind2 = inds;
    ind_lat1 = lat_ind(_lat1; res=ds.res_lat);
    ind_lat2 = lat_ind(_lat2; res=ds.res_lat);
    ind_lon1 = lon_ind(_lon1; res=ds.res_lon);
    ind_lon2 = lon_ind(_lon2; res=ds.res_lon);

    return ds.data[ind_lon1:ind_lon2, ind_lat1:ind_lat2, _ind1:_ind2]
end
