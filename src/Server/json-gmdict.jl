"""

    gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)

Return a JSON string containing GriddingMachine dictionary data for the given location, given
- `user` User name for tracking purposes
- `gmversion` GriddingMachine version (e.g., "gm2", "gm3", "gm4")
- `year` Target year for time-dependent variables
- `lat` Target latitude
- `lon` Target longitude

The returned dictionary contains comprehensive land surface parameters including:
- General information (latitude, longitude, elevation, etc.)
- Environmental parameters (land mask, PFT fractions, CO2)
- Soil parameters (color, hydraulic properties)
- Canopy parameters (height, LAI, clumping index)
- Leaf parameters (chlorophyll, LMA, optical properties)
- Photosynthesis parameters (VCMAX25, JMAX25, stomatal conductance)

"""
function gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)
    # Try to read the data using grid_dict from Indexer module
    try
        # Create land dataset labels and get grid dictionary
        gm_dict = grid_dict(LandDatasetLabels(gmversion, year), lat, lon);

        # Prepare response dictionary
        json_dict = Dict{String,Any}(
            "Note"            => "Unregistered users need to wait for 2 seconds to avoid malicious attack.",
            "User"            => user,
            "GM Version"      => gmversion,
            "Year"            => year,
            "Latitude"        => lat,
            "Longitude"       => lon,
            "GM Dict"         => gm_dict,
        );

        return GRJSON.json(json_dict)

    catch e
        # Return error message if request fails
        json_warn = Dict{String,Any}(
            "Note"            => "Unregistered users need to wait for 2 seconds to avoid malicious attack.",
            "Warning"         => "Your request cannot be completed, please check your settings",
            "User"            => user,
            "GM Version"      => gmversion,
            "Year"            => year,
            "Latitude"        => lat,
            "Longitude"       => lon,
            "Error Message"   => string(e),
        );

        return GRJSON.json(json_warn)
    end;
end;
