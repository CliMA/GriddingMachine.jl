###############################################################################
#
# Download ERA5 regenerated weather file
#
###############################################################################
ERA5_LAND_ALL = [
            "10m_u_component_of_wind",
            "10m_v_component_of_wind",
            "2m_dewpoint_temperature",
            "2m_temperature",
            "evaporation_from_bare_soil",
            "evaporation_from_open_water_surfaces_excluding_oceans",
            "evaporation_from_the_top_of_canopy",
            "evaporation_from_vegetation_transpiration",
            "forecast_albedo",
            "lake_bottom_temperature",
            "lake_ice_depth",
            "lake_ice_temperature",
            "lake_mix_layer_depth",
            "lake_mix_layer_temperature",
            "lake_shape_factor",
            "lake_total_layer_temperature",
            "leaf_area_index_high_vegetation",
            "leaf_area_index_low_vegetation",
            "potential_evaporation",
            "runoff",
            "skin_reservoir_content",
            "skin_temperature",
            "snow_albedo",
            "snow_cover",
            "snow_density",
            "snow_depth",
            "snow_depth_water_equivalent",
            "snow_evaporation",
            "snowfall",
            "snowmelt",
            "soil_temperature_level_1",
            "soil_temperature_level_2",
            "soil_temperature_level_3",
            "soil_temperature_level_4",
            "sub_surface_runoff",
            "surface_latent_heat_flux",
            "surface_net_solar_radiation",
            "surface_net_thermal_radiation",
            "surface_pressure",
            "surface_runoff",
            "surface_sensible_heat_flux",
            "surface_solar_radiation_downwards",
            "surface_thermal_radiation_downwards",
            "temperature_of_snow_layer",
            "total_evaporation",
            "total_precipitation",
            "volumetric_soil_water_layer_1",
            "volumetric_soil_water_layer_2",
            "volumetric_soil_water_layer_3",
            "volumetric_soil_water_layer_4"];
ERA5_LAND_SELECTION = [
            "10m_u_component_of_wind",
            "10m_v_component_of_wind",
            "2m_dewpoint_temperature",
            "2m_temperature",
            "evaporation_from_vegetation_transpiration",
            "leaf_area_index_high_vegetation",
            "leaf_area_index_low_vegetation",
            "skin_temperature",
            "surface_pressure",
            "surface_solar_radiation_downwards",];
ERA5_LAND_TIMES = [
            "00:00", "01:00", "02:00", "03:00", "04:00", "05:00",
            "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
            "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
            "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"];
ERA5_SINGLE_LEVELS_SELECTION =[
            "mean_surface_direct_short_wave_radiation_flux",
            "mean_surface_downward_short_wave_radiation_flux",
            "soil_temperature_level_1",
            "soil_temperature_level_2",
            "soil_temperature_level_3",
            "soil_temperature_level_4",
            "soil_type",
            "volumetric_soil_water_layer_1",
            "volumetric_soil_water_layer_2",
            "volumetric_soil_water_layer_3",
            "volumetric_soil_water_layer_4"];




"""
    fetch_ERA5!(dt::ERA5LandHourly,
                lat_ind::Int,
                lon_ind::Int,
                year::Int = 2020,
                month::Int = 6;
                vars::Array{String,1} = ERA5_LAND_ALL,
                times::Array{String,1} = ERA5_LAND_TIMES,
                folder::String = ""
    )
    fetch_ERA5!(dt::ERA5LandHourly,
                lat_ind::Int,
                lon_ind::Int,
                year::Int;
                vars::Array{String,1} = ERA5_LAND_ALL,
                times::Array{String,1} = ERA5_LAND_TIMES,
                folder::String = ""
    )

Download dataset per 1 by 1 degree, given
- `dt` Dataset type
- `lat_ind` Latitude index (0 for -90~-89, 90 for -1~0)
- `lon_ind` Longitude index (0 for -180~-179, 180 for -1~0)
- `year` Which year of data to download, default = 2020
- `month` Which month of data to download, default = 6 (June)
- `vars` Variables to download, default is `ERA5_LAND_ALL`
- `times` Time list to download, default is all 24 hours
- `folder` Folder to save the downloaded dataset, default is "" (current dir)
"""
function fetch_ERA5!(
            dt::ERA5LandHourly,
            lat_ind::Int,
            lon_ind::Int,
            year::Int,
            month::Int;
            vars::Array{String,1} = ERA5_LAND_ALL,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading land data for year $(year) month $(month)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    # set lat and lon bounds
    lat1 = lat_ind - 91;
    lat2 = lat_ind - 90;
    lon1 = lon_ind - 181;
    lon2 = lon_ind - 180;

    # file name to save the downloaded dataset
    file_name = "$(folder)ERA5_LAND_$(year)_$(month)_$(lat_ind)_$(lon_ind).nc";

    # retrieve data if file does not exist
    if !isfile(file_name)
        CDSAPI_CLIENT.retrieve(
            "reanalysis-era5-land",
            Dict(
                "format"   => "netcdf",
                "variable" => vars,
                "year"     => "$(year)",
                "month"    => "$(month)",
                "day"      => ["$(i)" for i in 1:month_days(year,month)],
                "time"     => times,
                "area"     => ["$(lat2)", "$(lon1)", "$(lat1)", "$(lon2)"],
            ),
            file_name
        );
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5LandHourly,
            lat_ind::Int,
            lon_ind::Int,
            year::Int;
            vars::Array{String,1} = ERA5_LAND_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading land data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    # set lat and lon bounds
    lat1 = lat_ind - 91;
    lat2 = lat_ind - 90;
    lon1 = lon_ind - 181;
    lon2 = lon_ind - 180;

    # file name to save the downloaded dataset
    file_name = "$(folder)ERA5_LAND_$(year)_$(lat_ind)_$(lon_ind).nc";

    # retrieve data if file does not exist
    if !isfile(file_name)
        CDSAPI_CLIENT.retrieve(
            "reanalysis-era5-land",
            Dict(
                "format"   => "netcdf",
                "variable" => vars,
                "year"     => "$(year)",
                "month"    => ["$(i)" for i in 1:12],
                "day"      => ["$(i)" for i in 1:31],
                "time"     => times,
                "area"     => ["$(lat2)", "$(lon1)", "$(lat1)", "$(lon2)"],
            ),
            file_name
        );
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5LandHourly,
            year::Int;
            vars::Array{String,1} = ERA5_LAND_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading land data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    # file name to save the downloaded dataset
    file_name = "$(folder)ERA5_LAND_$(year).nc";

    # retrieve data if file does not exist
    if !isfile(file_name)
        CDSAPI_CLIENT.retrieve(
            "reanalysis-era5-land",
            Dict(
                "format"   => "netcdf",
                "variable" => vars,
                "year"     => "$(year)",
                "month"    => ["$(i)" for i in 1:12],
                "day"      => ["$(i)" for i in 1:31],
                "time"     => times,
            ),
            file_name
        );
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5LandHourly,
            year::Int,
            per_item::Bool;
            vars::Array{String,1} = ERA5_LAND_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading land data for year $(year) per item...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    for _item in vars
        @info "Querying $(_item)";

        # file name to save the downloaded dataset
        file_name = "$(folder*_item)_LAND_$(year).nc";

        # retrieve data if file does not exist
        if !isfile(file_name)
            CDSAPI_CLIENT.retrieve(
                "reanalysis-era5-land",
                Dict(
                    "format"   => "netcdf",
                    "variable" => _item,
                    "year"     => "$(year)",
                    "month"    => ["$(i)" for i in 1:12],
                    "day"      => ["$(i)" for i in 1:31],
                    "time"     => times,
                ),
                file_name
            );
        end
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5SingleLevelsHourly,
            lat_ind::Int,
            lon_ind::Int,
            year::Int;
            vars::Array{String,1} = ERA5_SINGLE_LEVELS_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading single levels data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    # set lat and lon bounds
    lat1 = lat_ind - 91;
    lat2 = lat_ind - 90;
    lon1 = lon_ind - 181;
    lon2 = lon_ind - 180;

    # file name to save the downloaded dataset
    file_name = "$(folder)ERA5_SL_$(year)_$(lat_ind)_$(lon_ind).nc";

    # retrieve data if file does not exist
    if !isfile(file_name)
        CDSAPI_CLIENT.retrieve(
            "reanalysis-era5-single-levels",
            Dict(
                "product_type" => "reanalysis",
                "format"       => "netcdf",
                "variable"     => vars,
                "year"         => "$(year)",
                "month"        => ["$(i)" for i in 1:12],
                "day"          => ["$(i)" for i in 1:31],
                "time"         => times,
                "area"         => ["$(lat2)", "$(lon1)", "$(lat1)", "$(lon2)"],
            ),
            file_name
        );
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5SingleLevelsHourly,
            year::Int;
            vars::Array{String,1} = ERA5_SINGLE_LEVELS_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading single levels data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    # file name to save the downloaded dataset
    file_name = "$(folder)ERA5_SL_$(year).nc";

    # retrieve data if file does not exist
    if !isfile(file_name)
        CDSAPI_CLIENT.retrieve(
            "reanalysis-era5-single-levels",
            Dict(
                "product_type" => "reanalysis",
                "format"       => "netcdf",
                "variable"     => vars,
                "year"         => "$(year)",
                "month"        => ["$(i)" for i in 1:12],
                "day"          => ["$(i)" for i in 1:31],
                "time"         => times,
            ),
            file_name
        );
    end

    return nothing
end




function fetch_ERA5!(
            dt::ERA5SingleLevelsHourly,
            year::Int,
            per_item::Bool;
            vars::Array{String,1} = ERA5_SINGLE_LEVELS_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading single levels data for year $(year) per item...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT;
    update_CDSAPI_password!();

    for _item in vars
        @info "Querying $(_item)";

        # file name to save the downloaded dataset
        file_name = "$(folder*_item)_SL_$(year).nc";

        # retrieve data if file does not exist
        if !isfile(file_name)
            CDSAPI_CLIENT.retrieve(
                "reanalysis-era5-single-levels",
                Dict(
                    "product_type" => "reanalysis",
                    "format"       => "netcdf",
                    "variable"     => _item,
                    "year"         => "$(year)",
                    "month"        => ["$(i)" for i in 1:12],
                    "day"          => ["$(i)" for i in 1:31],
                    "time"         => times,
                ),
                file_name
            );
        end
    end

    return nothing
end
