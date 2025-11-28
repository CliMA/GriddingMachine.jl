""" Structure to save weather drivers from GriddingMachine for global simulations (labels only) """
Base.@kwdef mutable struct WeatherDriverLabels
    "Weather driver version"
    wd_tag::String
    "Which year do the datasets apply (when applicable)"
    year::Int
    "Spatial resolution zoom factor, resolution is 1/nx °"
    nx::Int
    "GriddingMachine.jl tag for surface pressure"
    tag_patm::String
    "GriddingMachine.jl tag for precipitation"
    tag_ppt::String
    "GriddingMachine.jl tag for radiation (diffuse shortwave)"
    tag_rad_dif::String
    "GriddingMachine.jl tag for radiation (direct shortwave)"
    tag_rad_dir::String
    "GriddingMachine.jl tag for radiation (longwave)"
    tag_rad_lw::String
    "GriddingMachine.jl tag for air temperature"
    tag_t_air::String
    "GriddingMachine.jl tag for vapor pressure deficit"
    tag_vpd::String
    "GriddingMachine.jl tag for wind speed"
    tag_wind::String
end;

"""

    WeatherDriverLabels(wd_tag::String, year::Int)

Constructor of WeatherDriverLabels, given
- `wd_tag` version of GriddingMachine weather drivers
- `year` year of the weather drivers

"""
WeatherDriverLabels(wd_tag::String, year::Int) = (
    @assert wd_tag in ["wd1"] "Weather driver tag $(wd_tag) is not supported!";

    if wd_tag == "wd1"
        return WeatherDriverLabels(
                    wd_tag      = wd_tag,
                    year        = year,
                    nx          = 1,
                    tag_patm    = "PATM_ERA5_1X_1H_$(year)_V1",
                    tag_ppt     = "PPT_ERA5_1X_1H_$(year)_V1",
                    tag_rad_dif = "RAD_SW_DIF_ERA5_1X_1H_$(year)_V1",
                    tag_rad_dir = "RAD_SW_DIR_ERA5_1X_1H_$(year)_V1",
                    tag_rad_lw  = "RAD_LW_ERA5_1X_1H_$(year)_V1",
                    tag_t_air   = "TAIR_ERA5_1X_1H_$(year)_V1",
                    tag_vpd     = "VPD_ERA5_1X_1H_$(year)_V1",
                    tag_wind    = "WIND_ERA5_1X_1H_$(year)_V1")
    end;

    return error("Tag $(wd_tag) is not supported!")
);


""" Structure to save gridded datasets from GriddingMachine for global simulations """
Base.@kwdef mutable struct WeatherDrivers{FT<:AbstractFloat}
    # labels for the datasets
    "Land dataset labels"
    LABELS::WeatherDriverLabels

    # weather drivers
    "Surface air pressure"
    patm::Array{FT} = regrid(read_dataset(LABELS.tag_patm), LABELS.nx);
    "Precipitation"
    ppt::Array{FT} = regrid(read_dataset(LABELS.tag_ppt), LABELS.nx);
    "Diffuse shortwave radiation"
    rad_dif::Array{FT} = regrid(read_dataset(LABELS.tag_rad_dif), LABELS.nx);
    "Direct shortwave radiation"
    rad_dir::Array{FT} = regrid(read_dataset(LABELS.tag_rad_dir), LABELS.nx);
    "Longwave radiation"
    rad_lw::Array{FT} = regrid(read_dataset(LABELS.tag_rad_lw), LABELS.nx);
    "Air temperature"
    t_air::Array{FT} = regrid(read_dataset(LABELS.tag_t_air), LABELS.nx);
    "Vapor pressure deficit"
    vpd::Array{FT} = regrid(read_dataset(LABELS.tag_vpd), LABELS.nx);
    "Wind speed"
    wind::Array{FT} = regrid(read_dataset(LABELS.tag_wind), LABELS.nx);
end;

"""

    WeatherDrivers{FT}(wd_tag::String, year::Int) where {FT}

Constructor of WeatherDrivers, given
- `wd_tag` Unique tag of GriddingMachine weather drivers
- `year` year of simulations

"""
WeatherDrivers{FT}(wd_tag::String, year::Int; msg_level::String = "tinfo") where {FT} = (
    dtl = WeatherDriverLabels(wd_tag, year);

    pretty_display!("Querying weather drivers from GriddingMachine...", msg_level);
    dts = WeatherDrivers{FT}(LABELS = dtl);

    return dts
);
