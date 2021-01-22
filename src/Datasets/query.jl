###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    query_LUT(dt::AbstractDataset)
    query_LUT(dt::AbstractDataset, res_g::String)
    query_LUT(dt::AbstractDataset, year::Int, res_g::String, res_t::String)

Query the file location from artifacts, given
- `dt` Dataset type, subtype of [`AbstractDataset`](@ref)
- `year` Which year
- `res_g` Resolution in degree
- `res_t` Resolution in time

Return the following:
- Path to artifact data file
- Format of the data
- Variable name of NC file or Band of Tiff file
- Time resolution
- Whether latitude is reversed
- Variable name of gridded data
- Variable attribute of gridded data
"""
function query_LUT(dt::CanopyHeightGLAS)
    _file = artifact"canopy_height_20X_1Y" * "/canopy_height_20X_1Y.nc";
    _varn = "CH";
    _vara = Dict("longname" => "Canopy height" , "units" => "m");

    return _file, FormatNC(), "Band1", "1Y", false, _varn, _vara
end




function query_LUT(dt::ClumpingIndexMODIS, res_g::String, res_t::String)
    if (res_g=="240X") && (res_t=="1Y")
        _file = artifact"clumping_index_240X_1Y" *
                "/global_clumping_index_240X_WGS84.tif";
    elseif (res_g=="12X") && (res_t=="1Y")
        _file = artifact"clumping_index_12X_1Y" *
                "/global_clumping_index_12X_WGS84.tif";
    end
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index" , "units" => "-");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end




function query_LUT(dt::ClumpingIndexPFT)
    _file = artifact"clumping_index_2X_1Y_PFT" *
            "/global_clumping_index_2X_PFT.nc";
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index" , "units" => "-");

    return _file, FormatNC(), "clump", "1Y", false, _varn, _vara
end




function query_LUT(dt::FloodPlainHeight)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "FloodPlainHeight";
    _vara = Dict("longname" => "Flood plain height",
                 "units"    => "m")

    return _file, FormatNC(), "fldhgt", "1Y", true, _varn, _vara
end




function query_LUT(dt::GPPMPIv006, year::Int, res_g::String, res_t::String)
    if (res_g == "1X") && (res_t=="8D")
        _name = "GPP_MPI_v006_1X_8D_" * string(year) * ".nc";
        _arti = artifact"GPP_MPI_v006_1X_8D";
        _revl = false;
    elseif (res_g == "2X") && (res_t=="8D")
        _name = "GPP_MPI_v006_2X_8D_" * string(year) * ".nc";
        _arti = artifact"GPP_MPI_v006_2X_8D";
        _revl = true;
    elseif (res_g == "2X") && (res_t=="1M")
        _name = "GPP_MPI_v006_2X_1M_" * string(year) * ".nc";
        _arti = artifact"GPP_MPI_v006_2X_1M";
        _revl = true;
    end
    _file = joinpath(_arti, _name);
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, _revl, _varn, _vara
end




function query_LUT(dt::GPPVPMv20, year::Int, res_g::String, res_t::String)
    if (res_g == "1X") && (res_t=="8D")
        _name = "GPP_VPM_v20_1X_8D_" * string(year) * ".nc";
        _arti = artifact"GPP_VPM_v20_1X_8D";
        _revl = false;
    elseif (res_g == "5X") && (res_t=="8D")
        _name = "GPP_VPM_v20_5X_8D_" * string(year) * ".nc";
        _arti = artifact"GPP_VPM_v20_5X_8D";
        _revl = true;
    elseif (res_g == "12X") && (res_t=="8D")
        _name = "GPP_VPM_v20_12X_8D_" * string(year) * ".nc";
        _arti = artifact"GPP_VPM_v20_12X_8D";
        _revl = true;
    end
    _file = joinpath(_arti, _name);
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, _revl, _varn, _vara
end




function query_LUT(dt::LAIMonthlyMean)
    _file = artifact"leaf_area_index_4X_1M" * "/leaf_area_index_4X_1M.nc";
    _varn = "LAI";
    _vara = Dict("longname" => "Leaf area index", "units" => "-");

    return _file, FormatNC(), "LAI", "1M", false, _varn, _vara
end




function query_LUT(dt::LandElevation)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "Elevation";
    _vara = Dict("longname" => "Elevation",
                 "units"    => "m")

    return _file, FormatNC(), "elevtn", "1Y", true, _varn, _vara
end




function query_LUT(dt::LandMaskERA5)
    _file = artifact"land_mask_ERA5_4X_1Y" * "/land_mask_ERA5_4X_1Y.nc";
    _varn = "LM";
    _vara = Dict("longname" => "Land mask", "units" => "-");

    return _file, FormatNC(), "lsm", "1M", false, _varn, _vara
end




function query_LUT(dt::LeafChlorophyll)
    _file = artifact"leaf_chlorophyll_2X_7D" *
            "/leaf_chlorophyll_2X_7D.nc";
    _varn = "LC";
    _vara = Dict("longname" => "Leaf chlorophyll content",
                 "units" => "μg cm⁻²");

    return _file, FormatNC(), "chl", "7D", true, _varn, _vara
end




function query_LUT(dt::LeafNitrogen)
    _file = artifact"leaf_traits_2X_1Y" * "/leaf_nitrogen_2X_1Y.nc";
    _varn = "LN";
    _vara = Dict("longname" => "Leaf nitrogen content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_nitrogen_content_mean", "1Y", false,
           _varn, _vara
end




function query_LUT(dt::LeafPhosphorus)
    _file = artifact"leaf_traits_2X_1Y" * "/leaf_phosphorus_2X_1Y.nc";
    _varn = "LP";
    _vara = Dict("longname" => "Leaf phosphorus content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_phosphorus_content_mean", "1Y", false,
           _varn, _vara
end




function query_LUT(dt::LeafSLA)
    _file = artifact"leaf_traits_2X_1Y" * "/specific_leaf_area_2X_1Y.nc";
    _varn = "SLA";
    _vara = Dict("longname" => "Specific leaf area",
                 "units" => "m² kg⁻¹");

    return _file, FormatNC(), "specific_leaf_area_mean", "1Y", false,
           _varn, _vara
end




function query_LUT(dt::NPPModis)
    _file = artifact"NPP_MODIS_1X_1Y" * "/npp_modis_1X_1Y_2000.nc";
    _varn = "NPP";
    _vara = Dict("longname" => "Net primary productivity",
                 "units"    => "kg C m⁻² s⁻¹")

    return _file, FormatNC(), "npp", "1Y", false, _varn, _vara
end




function query_LUT(dt::RiverHeight)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "RiverHeight";
    _vara = Dict("longname" => "River height",
                 "units"    => "m")

    return _file, FormatNC(), "rivhgt", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverLength)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "RiverLength";
    _vara = Dict("longname" => "River length",
                 "units"    => "m")

    return _file, FormatNC(), "rivlen", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverManning)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "RiverManning";
    _vara = Dict("longname" => "River manning coefficient",
                 "units"    => "-")

    return _file, FormatNC(), "rivman", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverWidth)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "RiverWidth";
    _vara = Dict("longname" => "River width",
                 "units"    => "m")

    return _file, FormatNC(), "rivwth", "1Y", true, _varn, _vara
end




function query_LUT(dt::SIFTropomi740, year::Int, res_g::String, res_t::String)
    if (res_g == "1X") && (res_t=="1M")
        _name = "SIF_TROPOMI_740_1X_1M_" * string(year) * ".nc";
        _arti = artifact"SIF_TROPOMI_740_1X_1M";
        _revl = false;
    elseif (res_g == "12X") && (res_t=="8D")
        _name = "SIF_TROPOMI_740_12X_8D_" * string(year) * ".nc";
        _arti = artifact"SIF_TROPOMI_740_12X_8D";
        _revl = false;
    end
    _file = joinpath(_arti, _name);
    _varn = "SIF";
    _vara = Dict("longname" => "Sun induced fluoresence",
                 "units" => "mW m⁻² sr⁻¹ nm⁻¹");

    return _file, FormatNC(), "sif", res_t, _revl, _varn, _vara
end




function query_LUT(dt::TreeDensity, res_g::String, res_t::String)
    if (res_g=="120X") && (res_t=="1Y")
        _file = artifact"tree_density_120X_1Y" *
                "/tree_density_120X_1Y_WGS84.tif";
    elseif (res_g=="12X") && (res_t=="1Y")
        _file = artifact"tree_density_12X_1Y" *
                "/tree_density_12X_1Y_WGS84.tif";
    end
    _varn = "TD";
    _vara = Dict("longname" => "Tree density" , "units" => "km⁻²");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end




function query_LUT(dt::UnitCatchmentArea)
    _file = artifact"river_maps_4X_1Y" * "/river_maps_4X_1Y.nc";
    _varn = "UnitCatchmentArea";
    _vara = Dict("longname" => "Unit catchment area",
                 "units"    => "m²")

    return _file, FormatNC(), "ctmare", "1Y", true, _varn, _vara
end




function query_LUT(dt::WoodDensity)
    _file = artifact"wood_density_2X_1Y" * "/wood_density_2X_1Y.tif";
    _varn = "WD";
    _vara = Dict("longname" => "Wood density" , "units" => "g cm⁻³");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end
