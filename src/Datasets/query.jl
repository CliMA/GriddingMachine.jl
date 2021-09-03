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
- Variable name of NC file
- Time resolution
- Whether latitude is reversed
- Variable name of gridded data
- Variable attribute of gridded data
- Variable range limits (beyond which NaN ought to apply)
"""
function query_LUT(
            dt::GPPMPIv006{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "GPP_MPI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact!(_artn, ARTIFACTs_TOML);
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
    predownload_artifact!(_artn, ARTIFACTs_TOML);
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
    predownload_artifact!(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LAI";
    _vara = Dict("longname" => "Leaf area index", "units" => "-");

    return _file, FormatNC(), "lai", res_t, true, _varn, _vara, FT[eps(FT),20]
end




function query_LUT(dt::LeafChlorophyll{FT}) where {FT<:AbstractFloat}
    @warn "Note that this chloropgyll dataset is not meant for public use...";
    _artn = "CHL_2X_7D_V1";
    predownload_artifact!(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "LC";
    _vara = Dict("longname" => "Leaf chlorophyll content",
                 "units" => "μg cm⁻²");

    return _file, FormatNC(), "chl", "7D", true, _varn, _vara, FT[eps(FT),200]
end




function query_LUT(
            dt::SIFTropomi740{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "SIF740_TROPOMI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact!(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SIF";
    _vara = Dict("longname" => "Sun induced fluoresence",
                 "units" => "mW m⁻² sr⁻¹ nm⁻¹");

    return _file, FormatNC(), "sif", res_t, false, _varn, _vara, FT[-2,10]
end




function query_LUT(
            dt::SIFTropomi740DC{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "SIF740_TROPOMI_$(res_g)_$(res_t)_$(year)_V1";
    predownload_artifact!(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SIFDC";
    _vara = Dict("longname" => "Day length corrected sun induced fluoresence",
                 "units" => "mW m⁻² sr⁻¹ nm⁻¹");

    return _file, FormatNC(), "sif_dc", res_t, false, _varn, _vara, FT[-20,90]
end




function query_LUT(
            dt::VGMAlphaJules{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _artn = "VGM_ALPHA_$(res_g)_$(res_t)_V1";
    predownload_artifact!(_artn, ARTIFACTs_TOML);
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
    predownload_artifact!(_artn, ARTIFACTs_TOML);
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
    predownload_artifact!(_artn, ARTIFACTs_TOML);
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
    predownload_artifact!(_artn, ARTIFACTs_TOML);
    _file = @artifact_str(_artn) * "/$(_artn).nc";
    _varn = "SWCS";
    _vara = Dict("longname" => "van Genuchten Θr",
                 "units"    => "-");

    return _file, FormatNC(), "SWCS", res_t, false, _varn, _vara, FT[eps(FT),1]
end
