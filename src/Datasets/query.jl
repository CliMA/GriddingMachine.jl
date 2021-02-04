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
    _file = artifact"CH_20X_1Y_V1" * "/CH_20X_1Y_V1.nc";
    _varn = "CH";
    _vara = Dict("longname" => "Canopy height" , "units" => "m");

    return _file, FormatNC(), "Band1", "1Y", false, _varn, _vara
end




function query_LUT(dt::ClumpingIndexMODIS, res_g::String, res_t::String)
    _file = @artifact_str("CI_$(res_g)_$(res_t)_V1") *
            "/CI_$(res_g)_$(res_t)_V1.tif";
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index" , "units" => "-");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end




function query_LUT(dt::ClumpingIndexPFT)
    _file = artifact"CI_PFT_2X_1Y_V1" * "/CI_PFT_2X_1Y_V1.nc";
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index" , "units" => "-");

    return _file, FormatNC(), "clump", "1Y", false, _varn, _vara
end




function query_LUT(dt::FloodPlainHeight)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "FloodPlainHeight";
    _vara = Dict("longname" => "Flood plain height",
                 "units"    => "m")

    return _file, FormatNC(), "fldhgt", "1Y", true, _varn, _vara
end




function query_LUT(dt::GPPMPIv006, year::Int, res_g::String, res_t::String)
    _file = @artifact_str("GPP_MPI_$(res_g)_$(res_t)_$(year)_V1") *
            "/GPP_MPI_$(res_g)_$(res_t)_$(year)_V1.nc";
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, true, _varn, _vara
end




function query_LUT(dt::GPPVPMv20, year::Int, res_g::String, res_t::String)
    _file = @artifact_str("GPP_VPM_$(res_g)_$(res_t)_$(year)_V1") *
            "/GPP_VPM_$(res_g)_$(res_t)_$(year)_V1.nc";
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, true, _varn, _vara
end




function query_LUT(dt::LAIMonthlyMean)
    _file = artifact"LAI_4X_1M_V1" * "/LAI_4X_1M_V1.nc";
    _varn = "LAI";
    _vara = Dict("longname" => "Leaf area index", "units" => "-");

    return _file, FormatNC(), "LAI", "1M", false, _varn, _vara
end




function query_LUT(dt::LandElevation)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "Elevation";
    _vara = Dict("longname" => "Elevation",
                 "units"    => "m")

    return _file, FormatNC(), "elevtn", "1Y", true, _varn, _vara
end




function query_LUT(dt::LandMaskERA5)
    _file = artifact"LM_ERA5_4X_1Y_V1" * "/LM_ERA5_4X_1Y_V1.nc";
    _varn = "LM";
    _vara = Dict("longname" => "Land mask", "units" => "-");

    return _file, FormatNC(), "lsm", "1M", false, _varn, _vara
end




function query_LUT(dt::LeafChlorophyll)
    _file = artifact"CHL_2X_7D_V1" * "/CHL_2X_7D_V1.nc";
    _varn = "LC";
    _vara = Dict("longname" => "Leaf chlorophyll content",
                 "units" => "μg cm⁻²");

    return _file, FormatNC(), "chl", "7D", true, _varn, _vara
end




function query_LUT(dt::LeafNitrogen)
    _file = artifact"LNC_2X_1Y_V1" * "/LNC_2X_1Y_V1.nc";
    _varn = "LN";
    _vara = Dict("longname" => "Leaf nitrogen content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_nitrogen_content_mean", "1Y", false,
           _varn, _vara
end




function query_LUT(dt::LeafPhosphorus)
    _file = artifact"LPC_2X_1Y_V1" * "/LPC_2X_1Y_V1.nc";
    _varn = "LP";
    _vara = Dict("longname" => "Leaf phosphorus content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_phosphorus_content_mean", "1Y", false,
           _varn, _vara
end




function query_LUT(dt::LeafSLA)
    _file = artifact"SLA_2X_1Y_V1" * "/SLA_2X_1Y_V1.nc";
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
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "RiverHeight";
    _vara = Dict("longname" => "River height",
                 "units"    => "m")

    return _file, FormatNC(), "rivhgt", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverLength)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "RiverLength";
    _vara = Dict("longname" => "River length",
                 "units"    => "m")

    return _file, FormatNC(), "rivlen", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverManning)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "RiverManning";
    _vara = Dict("longname" => "River manning coefficient",
                 "units"    => "-")

    return _file, FormatNC(), "rivman", "1Y", true, _varn, _vara
end




function query_LUT(dt::RiverWidth)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "RiverWidth";
    _vara = Dict("longname" => "River width",
                 "units"    => "m")

    return _file, FormatNC(), "rivwth", "1Y", true, _varn, _vara
end




function query_LUT(dt::SIFTropomi740, year::Int, res_g::String, res_t::String)
    _file = @artifact_str("SIF740_TROPOMI_$(res_g)_$(res_t)_$(year)_V1") *
            "/SIF740_TROPOMI_$(res_g)_$(res_t)_$(year)_V1.nc";
    _varn = "SIF";
    _vara = Dict("longname" => "Sun induced fluoresence",
                 "units" => "mW m⁻² sr⁻¹ nm⁻¹");

    return _file, FormatNC(), "sif", res_t, false, _varn, _vara
end




function query_LUT(dt::TreeDensity, res_g::String, res_t::String)
    _file = @artifact_str("TD_$(res_g)_$(res_t)_V1") *
            "/TD_$(res_g)_$(res_t)_V1.tif";
    _varn = "TD";
    _vara = Dict("longname" => "Tree density" , "units" => "km⁻²");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end




function query_LUT(dt::UnitCatchmentArea)
    _file = artifact"RIVER_4X_1Y_V1" * "/RIVER_4X_1Y_V1.nc";
    _varn = "UnitCatchmentArea";
    _vara = Dict("longname" => "Unit catchment area",
                 "units"    => "m²")

    return _file, FormatNC(), "ctmare", "1Y", true, _varn, _vara
end




function query_LUT(dt::WoodDensity)
    _file = artifact"WD_2X_1Y_V1" * "/WD_2X_1Y_V1.tif";
    _varn = "WD";
    _vara = Dict("longname" => "Wood density" , "units" => "g cm⁻³");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara
end
