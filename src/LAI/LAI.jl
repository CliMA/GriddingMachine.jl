###############################################################################
#
# Load monthly mean LAI matrix
#
###############################################################################
"""
    mean_LAI_map(FT)

Load average monthly LAI from year 1981 to 2015, given
- `FT` FLoating number type
- `filename` File location of mean gridded LAI

Note that the monthly mean LAI map starts from 1981-08-01, and thus `[:,:,1]`
    views the LAI for Augest, and `[:,:,12]` views that of July.
"""
function mean_LAI_map(FT)
    # read data
    _data = ncread(joinpath(artifact"lai_monthly_mean",
                            "lai_monthly_mean.nc4"),
                   "LAI");

    return MeanMonthlyLAI{FT}(FT(0.25), FT(0.25), FT.(_data))
end








###############################################################################
#
# Read LAI
#
###############################################################################
"""
    read_LAI(
                mat::MeanMonthlyLAI{FT},
                lat::FT,
                lon::FT,
                month::Int
    ) where {FT<:AbstractFloat}

Read the LAI from given
- `mat` [`MeanMonthlyLAI`](@ref) type struct
- `lat` Latitude
- `lon` Longitude
- `month` Month number from 1 to 12, or String
"""
function read_LAI(
            mat::MeanMonthlyLAI{FT},
            lat::FT,
            lon::FT,
            month::Int
) where {FT<:AbstractFloat}
    ind_lat = lat_ind(lat; res=mat.res_lat);
    ind_lon = lon_ind(lon; res=mat.res_lon);
    ind_mon = month<8 ? (month+5) : (month-7);

    return mat.LAI[ind_lon, ind_lat, ind_mon]
end
