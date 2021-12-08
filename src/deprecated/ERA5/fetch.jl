###############################################################################
#
# Download ERA5 regenerated weather file
#
###############################################################################
#=
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
    global CDSAPI_CLIENT, ERA5_LAND_ALL;
    update_CDSAPI_password!();

    # make sure data label is supported
    for _var in vars
        @assert _var in ERA5_LAND_ALL;
    end;

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
    end;

    return nothing
end;




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
    global CDSAPI_CLIENT, ERA5_LAND_ALL;
    update_CDSAPI_password!();

    # make sure data label is supported
    for _var in vars
        @assert _var in ERA5_LAND_ALL;
    end;

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
    end;

    return nothing
end;



function fetch_ERA5!(
            dt::ERA5LandHourly,
            year::Int;
            vars::Array{String,1} = ERA5_LAND_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading land data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT, ERA5_LAND_ALL;
    update_CDSAPI_password!();

    # make sure data label is supported
    for _var in vars
        @assert _var in ERA5_LAND_ALL;
    end;

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
    end;

    return nothing
end;




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
    global CDSAPI_CLIENT, ERA5_SINGLE_LEVELS_ALL;
    update_CDSAPI_password!();

    # make sure data label is supported
    for _var in vars
        @assert _var in ERA5_SINGLE_LEVELS_ALL;
    end;

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
    end;

    return nothing
end;




function fetch_ERA5!(
            dt::ERA5SingleLevelsHourly,
            year::Int;
            vars::Array{String,1} = ERA5_SINGLE_LEVELS_SELECTION,
            times::Array{String,1} = ERA5_LAND_TIMES,
            folder::String = ""
)
    @info "Downloading single levels data for year $(year)...";

    # set up CDSAPI_CLIENT
    global CDSAPI_CLIENT, ERA5_SINGLE_LEVELS_ALL;
    update_CDSAPI_password!();

    # make sure data label is supported
    for _var in vars
        @assert _var in ERA5_SINGLE_LEVELS_ALL;
    end;

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
    end;

    return nothing
end;
=#
