###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    query_LUT(dt::AbstractDataset{FT}) where {FT<:AbstractFloat}
    query_LUT(dt::AbstractDataset{FT},
              res_g::String,
              res_t::String
    ) where {FT<:AbstractFloat}
    query_LUT(dt::AbstractDataset{FT},
              year::Int,
              res_g::String,
              res_t::String
    ) where {FT<:AbstractFloat}

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
- Variable range limits (beyond which NaN ought to apply)
"""
function query_LUT(dt::CanopyHeightBoonman{FT}) where {FT<:AbstractFloat}
    _artn = "CH_2X_1Y_V2";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "CH";
    _vara = Dict("longname" => "Canopy height", "units" => "m");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara, FT[eps(FT),200]
end




function query_LUT(dt::CanopyHeightGLAS{FT}) where {FT<:AbstractFloat}
    _artn = "CH_20X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "CH";
    _vara = Dict("longname" => "Canopy height", "units" => "m");

    return _file, FormatNC(), "Band1", "1Y", false, _varn, _vara,
           FT[eps(FT),200]
end




function query_LUT(
            dt::ClumpingIndexMODIS{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "CI_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index", "units" => "-");

    return _file, FormatTIFF(), 1, res_t, true, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::ClumpingIndexPFT{FT}) where {FT<:AbstractFloat}
    _artn = "CI_PFT_2X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "CI";
    _vara = Dict("longname" => "Clumping index", "units" => "-");

    return _file, FormatNC(), "clump", "1Y", false, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::FloodPlainHeight{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "FloodPlainHeight";
    _vara = Dict("longname" => "Flood plain height",
                 "units"    => "m");

    return _file, FormatNC(), "fldhgt", "1Y", true, _varn, _vara, FT[-100,9999]
end




function query_LUT(
            dt::GPPMPIv006{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "GPP_MPI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, true, _varn, _vara, FT[-10,100]
end




function query_LUT(
            dt::GPPVPMv20{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "GPP_VPM_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "GPP";
    _vara = Dict("longname" => "Gross primary productivity",
                 "units" => "μmol m⁻² s⁻¹");

    return _file, FormatNC(), "GPP", res_t, true, _varn, _vara, FT[-10,100]
end




function query_LUT(
            dt::LAIMODISv006{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "LAI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LAI";
    _vara = Dict("longname" => "Leaf area index", "units" => "-");

    return _file, FormatNC(), "lai", res_t, true, _varn, _vara, FT[eps(FT),20]
end




function query_LUT(dt::LAIMonthlyMean{FT}) where {FT<:AbstractFloat}
    _artn = "LAI_4X_1M_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LAI";
    _vara = Dict("longname" => "Leaf area index", "units" => "-");

    return _file, FormatNC(), "LAI", "1M", false, _varn, _vara, FT[eps(FT),20]
end




function query_LUT(dt::LandElevation{FT}) where {FT<:AbstractFloat}
    @warn "Note that this elevation dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "Elevation";
    _vara = Dict("longname" => "Elevation",
                 "units"    => "m");

    return _file, FormatNC(), "elevtn", "1Y", true, _varn, _vara,
           FT[-100,10000]
end




function query_LUT(dt::LandMaskERA5{FT}) where {FT<:AbstractFloat}
    _artn = "LM_ERA5_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LM";
    _vara = Dict("longname" => "Land mask", "units" => "-");

    return _file, FormatNC(), "lsm", "1Y", false, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::LeafChlorophyll{FT}) where {FT<:AbstractFloat}
    @warn "Note that this chloropgyll dataset is not meant for public use...";
    _artn = "CHL_2X_7D_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LC";
    _vara = Dict("longname" => "Leaf chlorophyll content",
                 "units" => "μg cm⁻²");

    return _file, FormatNC(), "chl", "7D", true, _varn, _vara, FT[eps(FT),200]
end




function query_LUT(dt::LeafNitrogenBoonman{FT}) where {FT<:AbstractFloat}
    _artn = "LNC_2X_1Y_V2";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "LN";
    _vara = Dict("longname" => "Leaf nitrogen content",
                 "units" => "kg kg⁻¹");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::LeafNitrogenButler{FT}) where {FT<:AbstractFloat}
    _artn = "LNC_2X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LN";
    _vara = Dict("longname" => "Leaf nitrogen content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_nitrogen_content_mean", "1Y", false,
           _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::LeafPhosphorus{FT}) where {FT<:AbstractFloat}
    _artn = "LPC_2X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LP";
    _vara = Dict("longname" => "Leaf phosphorus content",
                 "units" => "kg kg⁻¹");

    return _file, FormatNC(), "leaf_phosphorus_content_mean", "1Y", false,
           _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::LeafSLAButler{FT}) where {FT<:AbstractFloat}
    _artn = "SLA_2X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SLA";
    _vara = Dict("longname" => "Specific leaf area",
                 "units" => "m² kg⁻¹");

    return _file, FormatNC(), "specific_leaf_area_mean", "1Y", false,
           _varn, _vara, FT[eps(FT),100]
end




function query_LUT(dt::LeafSLABoonman{FT}) where {FT<:AbstractFloat}
    _artn = "SLA_2X_1Y_V2";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "SLA";
    _vara = Dict("longname" => "Specific leaf area",
                 "units" => "m² kg⁻¹");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara, FT[eps(FT),100]
end




function query_LUT(
            dt::NDVIAvhrr{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "NDVI_AVHRR_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "NDVI";
    _vara = Dict("longname" => "Normalized difference vegetation index",
                 "units" => "-");

    return _file, FormatNC(), "NDVI", res_t, true, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(
            dt::NIRoAvhrr{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "NIRO_AVHRR_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "NIRo";
    _vara = Dict("longname" => "NIRv with offset",
                 "units" => "-");

    return _file, FormatNC(), "NIRo", res_t, true, _varn, _vara, FT[-0.1,1]
end




function query_LUT(
            dt::NIRvAvhrr{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "NIRV_AVHRR_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "NIRv";
    _vara = Dict("longname" => "Near infrared reflection of vegetation",
                 "units" => "-");

    return _file, FormatNC(), "NIRv", res_t, true, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::NPPModis{FT}) where {FT<:AbstractFloat}
    _artn = "NPP_MODIS_1X_1Y";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/npp_modis_1X_1Y_2000.nc";
    _varn = "NPP";
    _vara = Dict("longname" => "Net primary productivity",
                 "units"    => "kg C m⁻² s⁻¹");

    return _file, FormatNC(), "npp", "1Y", false, _varn, _vara, FT[-Inf,Inf]
end




function query_LUT(dt::RiverHeight{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "RiverHeight";
    _vara = Dict("longname" => "River height",
                 "units"    => "m");

    return _file, FormatNC(), "rivhgt", "1Y", true, _varn, _vara,
           FT[-100,10000]
end




function query_LUT(dt::RiverLength{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "RiverLength";
    _vara = Dict("longname" => "River length",
                 "units"    => "m");

    return _file, FormatNC(), "rivlen", "1Y", true, _varn, _vara,
           FT[eps(FT),Inf]
end




function query_LUT(dt::RiverManning{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "RiverManning";
    _vara = Dict("longname" => "River manning coefficient",
                 "units"    => "-");

    return _file, FormatNC(), "rivman", "1Y", true, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::RiverWidth{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "RiverWidth";
    _vara = Dict("longname" => "River width",
                 "units"    => "m");

    return _file, FormatNC(), "rivwth", "1Y", true, _varn, _vara,
           FT[eps(FT),10000]
end




function query_LUT(
            dt::SIFTropomi740{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "SIF740_TROPOMI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SIF";
    _vara = Dict("longname" => "Sun induced fluoresence",
                 "units" => "mW m⁻² sr⁻¹ nm⁻¹");

    return _file, FormatNC(), "sif", res_t, false, _varn, _vara, FT[-2,10]
end




function query_LUT(
            dt::TreeDensity{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "TD_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "TD";
    _vara = Dict("longname" => "Tree density", "units" => "km⁻²");

    return _file, FormatTIFF(), 1, res_t, true, _varn, _vara, FT[eps(FT),Inf]
end




function query_LUT(dt::UnitCatchmentArea{FT}) where {FT<:AbstractFloat}
    @warn "Note that this river dataset is not meant for public use...";
    _artn = "RIVER_4X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "UnitCatchmentArea";
    _vara = Dict("longname" => "Unit catchment area",
                 "units"    => "m²");

    return _file, FormatNC(), "ctmare", "1Y", true, _varn, _vara,
           FT[eps(FT),Inf]
end




function query_LUT(
            dt::VGMAlphaJules{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "VGM_ALPHA_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "Alpha";
    _vara = Dict("longname" => "van Genuchten α",
                 "units"    => "MPa⁻¹");

    return _file, FormatNC(), "Alpha", res_t, false, _varn, _vara,
           FT[eps(FT),Inf]
end




function query_LUT(
            dt::VGMLogNJules{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "VGM_LOGN_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "logN";
    _vara = Dict("longname" => "van Genuchten log(n)",
                 "units"    => "-");

    return _file, FormatNC(), "logN", res_t, false, _varn, _vara,
           FT[eps(FT),10]
end




function query_LUT(
            dt::VGMThetaRJules{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "VGM_SWCR_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SWCR";
    _vara = Dict("longname" => "van Genuchten Θr",
                 "units"    => "-");

    return _file, FormatNC(), "SWCR", res_t, false, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(
            dt::VGMThetaSJules{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "VGM_SWCS_$(res_g)_$(res_t)_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SWCS";
    _vara = Dict("longname" => "van Genuchten Θr",
                 "units"    => "-");

    return _file, FormatNC(), "SWCS", res_t, false, _varn, _vara, FT[eps(FT),1]
end




function query_LUT(dt::WoodDensity{FT}) where {FT<:AbstractFloat}
    _artn = "WD_2X_1Y_V1";
    predownload_artifact(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).tif";
    _varn = "WD";
    _vara = Dict("longname" => "Wood density", "units" => "g cm⁻³");

    return _file, FormatTIFF(), 1, "1Y", true, _varn, _vara, FT[eps(FT),2]
end
