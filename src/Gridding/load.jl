###############################################################################
#
# Load MODIS grid information
#
###############################################################################
"""
    load_MODIS!(dt::AbstractUngriddedData) where {FT<:AbstractFloat}

Prepare parameters (file name and etc) to work on, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
"""
function load_MODIS!(dt::AbstractMODIS500m{FT}) where {FT<:AbstractFloat}
    # read MODIS gridding info
    @info "Please wait while loading MODIS tile information...";
    global MODIS_GRID_LAT, MODIS_GRID_LON;
    MODIS_GRID_LAT = FT.(ncread(artifact"MODIS_500m_grid" *
                                "/MODIS_500m_grid.nc",
                                "latitude"));
    MODIS_GRID_LON = FT.(ncread(artifact"MODIS_500m_grid" *
                                "/MODIS_500m_grid.nc",
                                "longitude"));

    return nothing
end




function load_MODIS!(dt::AbstractMODIS1km{FT}) where {FT<:AbstractFloat}
    # read MODIS gridding info
    @info "Please wait while loading MODIS tile information...";
    global MODIS_GRID_LAT, MODIS_GRID_LON;
    MODIS_GRID_LAT = FT.(ncread(artifact"MODIS_1km_grid" *
                                "/MODIS_1km_grid.nc",
                                "latitude"));
    MODIS_GRID_LON = FT.(ncread(artifact"MODIS_1km_grid" *
                                "/MODIS_1km_grid.nc",
                                "longitude"));

    return nothing
end
