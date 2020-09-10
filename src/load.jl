###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    load_LUT(dataset::MeanMonthlyLAI{FT}) where {FT<:AbstractFloat}
    load_LUT(dataset::MeanMonthlyLAI{FT}, year::Int, res_deg::Number) where {FT<:AbstractFloat}

Load look up table and return the struct, given
- `dataset` Dataset type (this function does not overwrite the `dataset`)
- `year` Which year
- `res_deg` Resolution in degree

Note that the artifact for GPP is about
- `500` MB for 0.2 degree resolution (5^2 * 360*180*46)
- `2600` MB for 0.083 degree resolution (12^2 * 360*180*46)
"""
function load_LUT(dataset::MeanMonthlyLAI{FT}) where {FT<:AbstractFloat}
    _LAI = FT.(ncread(joinpath(artifact"lai_monthly_mean",
                               "lai_monthly_mean.nc4"),
                      "LAI"));

    return MeanMonthlyLAI{FT}(LAI = _LAI);
end




function load_LUT(dataset::MeanMonthlyLAI{FT}, year::Int, res_deg::Number) where {FT<:AbstractFloat}
    if res_deg == 0.2
        _file = "GPP.VPM.v20." * string(year) * ".8-day.0.20_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_2_deg";
    elseif res_deg == 0.083
        _file = "GPP.VPM.v20." * string(year) * ".8-day.0.083_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_083_deg";
    end
    _gpp = FT.(ncread(joinpath(_arti, _file), "GPP"));

    return VPMGPPv20{FT}(GPP = _gpp);
end
