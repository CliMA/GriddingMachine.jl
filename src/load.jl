###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    load_LUT(dataset::GPPVPMv20{FT}, year::Int, res_geom::Number) where {FT<:AbstractFloat}
    load_LUT(dataset::LAIMonthlyMean{FT}) where {FT<:AbstractFloat}

Load look up table and return the struct, given
- `dataset` Dataset type (this function does not overwrite the `dataset`)
- `year` Which year
- `res_geom` Resolution in degree

Note that the artifact for GPP is about
- `500` MB for 0.2 degree resolution (5^2 * 360*180*46)
- `2600` MB for 0.083 degree resolution (12^2 * 360*180*46)
"""
function load_LUT(
            dataset::GPPMPIv006{FT},
            year::Int,
            res_geom::Number,
            res_time::String
) where {FT<:AbstractFloat}
    if (res_geom == 0.5) && (res_time=="8D")
        _file = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.8daily." *
                string(year) * ".nc";
        _arti = artifact"MPI_GPP_v006_0_5_deg_8D";
    elseif (res_geom == 0.5) && (res_time=="1M")
        _file = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.monthly." *
                string(year) * ".nc";
        _arti = artifact"MPI_GPP_v006_0_5_deg_1M";
    end
    _GPP = FT.(ncread(joinpath(_arti, _file), "GPP"));

    return GriddedDataset{FT}(data       = _GPP    ,
                              resolution = res_time,
                              data_type  = dataset )
end




function load_LUT(
            dataset::GPPVPMv20{FT},
            year::Int,
            res_geom::Number,
            res_time::String
) where {FT<:AbstractFloat}
    if (res_geom == 0.2) && (res_time=="8D")
        _file = "GPP.VPM.v20." * string(year) * ".8-day.0.20_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_2_deg_8D";
    elseif (res_geom == 0.083) && (res_time=="8D")
        _file = "GPP.VPM.v20." * string(year) * ".8-day.0.083_deg.nc";
        _arti = artifact"VPM_GPP_v20_0_083_deg_8D";
    end
    _GPP = FT.(ncread(joinpath(_arti, _file), "GPP"));

    return GriddedDataset{FT}(data       = _GPP    ,
                              resolution = res_time,
                              data_type  = dataset )
end




function load_LUT(dataset::LAIMonthlyMean{FT}) where {FT<:AbstractFloat}
    _LAI = FT.(ncread(joinpath(artifact"lai_monthly_mean",
                               "lai_monthly_mean.nc4"),
                      "LAI"));

    return GriddedDataset{FT}(data       = _LAI   ,
                              resolution = "1M"   ,
                              data_type  = dataset)
end




function load_LUT(dataset::VcmaxOptimalCiCa{FT}) where {FT<:AbstractFloat}
    _Vcmax = FT.(ncread(joinpath(artifact"vcmax_0_5_deg",
                                 "optimal_vcmax_globe.nc"),
                        "vcmax"));
    _Vcmax[ _Vcmax .< -100] .= NaN

    # note that lat of dataset does not start from -90 and end from 90
    # store the data into a new data array
    _NewVM::Array{FT,3} = zeros(FT, (720,360,1)) .* NaN;
    lat_array = collect(FT,83.75:-0.5:-55.75);
    for i in eachindex(lat_array)
        lat_indx = lat_ind(lat_array[i]; res = FT(0.5));
        _NewVM[:,lat_indx,1] .= _Vcmax[:,i];
    end

    return GriddedDataset{FT}(data       = _NewVM ,
                              res_lat    = FT(0.5),
                              res_lon    = FT(0.5),
                              resolution = "1Y"   ,
                              data_type  = dataset)
end
