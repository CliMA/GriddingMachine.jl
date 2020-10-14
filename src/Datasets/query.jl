###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    query_LUT(dt::AbstractDataset)
    query_LUT(dt::AbstractDataset, year::Int, res_g::Number, res_t::String)

Query the file location from artifacts,
- `dt` Dataset type, subtype of [`AbstractDataset`](@ref)
- `year` Which year
- `res_g` Resolution in degree
- `res_t` Resolution in time
"""
function query_LUT(dt::CanopyHeightGLAS)
    _file = artifact"canopy_height_0_05_deg" * "/canopy_height_0_05_deg.nc";
    return _file, FormatNC(), "Band1", "1Y", false
end




function query_LUT(dt::ClumpingIndexMODIS)
    _file = artifact"clumping_index_500_m" *
            "/global_clumping_index_WGS84.tif";
    return _file, FormatTIFF(), 1, "1Y", false
end




function query_LUT(dt::ClumpingIndexPFT)
    _file = artifact"clumping_index_0_5_deg_PFT" * "/clumping_factor_pft.nc";
    return _file, FormatNC(), "clump", "1Y", false
end




function query_LUT(dt::GPPMPIv006, year::Int, res_g::Number, res_t::String)
    if (res_g == 0.5) && (res_t=="8D")
        _name = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.8daily." *
                string(year) * ".nc";
        _arti = artifact"MPI_GPP_v006_0_5_deg_8D";
    elseif (res_g == 0.5) && (res_t=="1M")
        _name = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.monthly." *
                string(year) * ".nc";
        _arti = artifact"MPI_GPP_v006_0_5_deg_1M";
    end
    _file = joinpath(_arti, _name)

    return _file, FormatNC(), "GPP", res_t, true
end




function query_LUT(dt::GPPVPMv20, year::Int, res_g::Number, res_t::String)
    if (res_g == 0.2) && (res_t=="8D")
        _name = "GPP.VPM.v20." * string(year) * ".8-day.0.20_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_2_deg_8D";
    elseif (res_g == 0.083) && (res_t=="8D")
        _name = "GPP.VPM.v20." * string(year) * ".8-day.0.083_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_083_deg_8D";
    end
    _file = joinpath(_arti, _name);
    return _file, FormatNC(), "GPP", res_t, true
end




function query_LUT(dt::LAIMonthlyMean)
    _file = artifact"lai_monthly_mean" * "/lai_monthly_mean.nc4";
    return _file, FormatNC(), "LAI", "1M", false
end




function query_LUT(dt::LeafNitrogen)
    _file = artifact"leaf_sla_n_p_0_5_deg" * "/leaf_nitrogen.nc";
    return _file, FormatNC(), "leaf_nitrogen_content_mean", "1Y", false
end




function query_LUT(dt::LeafPhosphorus)
    _file = artifact"leaf_sla_n_p_0_5_deg" * "/leaf_phosphorus.nc";
    return _file, FormatNC(), "leaf_phosphorus_content_mean", "1Y", false
end




function query_LUT(dt::LeafSLA)
    _file = artifact"leaf_sla_n_p_0_5_deg" * "/leaf_sla.nc";
    return _file, FormatNC(), "specific_leaf_area_mean", "1Y", false
end




function query_LUT(dt::NPPModis)
    _file = artifact"npp_1_deg" * "/npp_modis_2000.nc";
    return _file, FormatNC(), "npp", "1Y", false
end
