#=
###############################################################################
#
# Load MODIS grid information
#
###############################################################################
"""
    load_MODIS(dt::AbstractUngriddedData) where {FT<:AbstractFloat}

Prepare parameters (file name and etc) to work on, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
"""
function load_MODIS(dt::AbstractMODIS500m{FT}, h::Int, v::Int) where {FT<:AbstractFloat}
    # read MODIS gridding info
    _file = artifact"MODIS_500m_grid" * "/MODIS_500m_grid.nc";

    _lat_mat = read_nc(FT, _file, "latitude" , h, v);
    _lon_mat = read_nc(FT, _file, "longitude", h, v);

    return _lat_mat,_lon_mat
end




function load_MODIS(dt::AbstractMODIS1km{FT}, h::Int, v::Int) where {FT<:AbstractFloat}
    # read MODIS gridding info
    _file = artifact"MODIS_1km_grid" * "/MODIS_1km_grid.nc";

    _lat_mat = read_nc(FT, _file, "latitude" , h, v);
    _lon_mat = read_nc(FT, _file, "longitude", h, v);

    return _lat_mat,_lon_mat
end
=#
