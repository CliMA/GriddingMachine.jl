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
