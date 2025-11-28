"""

    grid_weather(wds::WeatherDrivers{FT}, ilat::Int, ilon::Int; verification::Bool = true) where {FT}
    grid_weather(wdl::WeatherDriverLabels, lat::Number, lon::Number; FT::DataType = Float64, verification::Bool = true)

Read the weather drivers at a specific grid index, given
- `wds` WeatherDrivers struct
- `ilat` latitude index of the grid
- `ilon` longitude index of the grid
- `verification` if true, verify the output dictionary to make sure there is no NaN
- `wdl` WeatherDriverLabels struct
- `lat` latitude of the grid
- `lon` longitude of the grid
- `FT` data type of the output arrays

"""
function grid_weather end;

grid_weather(wds::WeatherDrivers{FT}, ilat::Int, ilon::Int; verification::Bool = true) where {FT<:AbstractFloat} = (
    # read the weather datasets for a specific grid index
    patm    = wds.patm[ilon,ilat,:];
    ppt     = wds.ppt[ilon,ilat,:];
    rad_dif = wds.rad_dif[ilon,ilat,:];
    rad_dir = wds.rad_dir[ilon,ilat,:];
    rad_lw  = wds.rad_lw[ilon,ilat,:];
    t_air   = wds.t_air[ilon,ilat,:];
    vpd     = wds.vpd[ilon,ilat,:];
    wind    = wds.wind[ilon,ilat,:];

    # create a dictionary to store the weather drivers (and verify it if needed)
    wd_dict = Dict{String,Any}(
                "PATM"       => patm,
                "PPT"        => ppt,
                "RAD_SW_DIF" => rad_dif,
                "RAD_SW_DIR" => rad_dir,
                "RAD_LW"     => rad_lw,
                "TAIR"       => t_air,
                "VPD"        => vpd,
                "WIND"       => wind);
    verification ? verify_dict!(wd_dict) : nothing;

    return wd_dict
);

grid_dict(wdl::WeatherDriverLabels, lat::Number, lon::Number; FT::DataType = Float64, verification::Bool = true) = (
    # read the land dataset for a specific grid (lat, lon)
    patm    = FT.(read_dataset(wdl.tag_patm   , lat, lon));
    ppt     = FT.(read_dataset(wdl.tag_ppt    , lat, lon));
    rad_dif = FT.(read_dataset(wdl.tag_rad_dif, lat, lon));
    rad_dir = FT.(read_dataset(wdl.tag_rad_dir, lat, lon));
    rad_lw  = FT.(read_dataset(wdl.tag_rad_lw , lat, lon));
    t_air   = FT.(read_dataset(wdl.tag_t_air  , lat, lon));
    vpd     = FT.(read_dataset(wdl.tag_vpd    , lat, lon));
    wind    = FT.(read_dataset(wdl.tag_wind   , lat, lon));

    # create a dictionary to store the weather drivers (and verify it if needed)
    wd_dict = Dict{String,Any}(
                "PATM"       => patm,
                "PPT"        => ppt,
                "RAD_SW_DIF" => rad_dif,
                "RAD_SW_DIR" => rad_dir,
                "RAD_LW"     => rad_lw,
                "TAIR"       => t_air,
                "VPD"        => vpd,
                "WIND"       => wind);
    verification ? verify_dict!(wd_dict) : nothing;

    return wd_dict
);
