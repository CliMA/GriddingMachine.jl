"""

    weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)

Return a JSON string containing weather driver data for the given location, given
- `user` User name for tracking purposes
- `wdversion` Weather driver version (e.g., "wd1" for ERA5 single level data)
- `year` Target year for weather data
- `lat` Target latitude
- `lon` Target longitude

The returned dictionary contains hourly weather data including:
- Air temperature (t_air)
- Air pressure (p_air)
- Wind speed (wind)
- Relative humidity (rh)
- Shortwave radiation (swdn)
- Longwave radiation (lwdn)
- Precipitation (rain)
- CO2 concentration (co2)

Note: This function requires Emerald.jl to be available.

"""
function weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)
    # Try to read and process weather data
    try
        # Validate weather driver version
        @assert wdversion in ["wd1"] "Weather driver tag $(wdversion) is not supported! Only 'wd1' (ERA5 single level) is available.";
        

        # Get weather data as DataFrame
        weather_dict = grid_weather(wdversion, year,lat, lon);

        # Prepare response dictionary
        json_dict = Dict{String,Any}(
            "Note"            => "Unregistered users need to wait for 2 seconds to avoid malicious attack.",
            "User"            => user,
            "WD Version"      => wdversion,
            "Year"            => year,
            "Latitude"        => lat,
            "Longitude"       => lon,
            "Weather Data"    => weather_dict,
        );

        return GRJSON.json(json_dict)

    catch e
        # Return error message if request fails
        json_warn = Dict{String,Any}(
            "Note"            => "Unregistered users need to wait for 2 seconds to avoid malicious attack.",
            "Warning"         => "Your weather data request cannot be completed, please check your settings",
            "User"            => user,
            "WD Version"      => wdversion,
            "Year"            => year,
            "Latitude"        => lat,
            "Longitude"       => lon,
            "Error Message"   => string(e),
        );

        return GRJSON.json(json_warn)
    end;
end;
