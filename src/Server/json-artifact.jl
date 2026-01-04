"""

    artifact_json(user::String, arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)

Return a JSON string containing the specified artifact data for the given location, given
- `user` User name for tracking purposes
- `arttag` Artifact tag (e.g., "CH_2X_1Y_V2")
- `lat` Target latitude
- `lon` Target longitude
- `cyc` Data cycle number (0 for all cycles, <1 for all cycles, ≥1 for specific cycle)
- `include_std` Whether to include standard deviation in the output (default: true)

Note: If standard deviation is not available in the dataset, "Error" field will contain "Not available in dataset".

"""
function artifact_json(user::String, arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)
    # If the arttag does not exist in current database, update the database (with rate limiting)
    global YAML_FILE_TIME;
    if !(arttag in YAML_TAGS)
        curr_time = now();
        dtime = seconds(curr_time - YAML_FILE_TIME);
        if dtime > 60
            update_database!();
            YAML_FILE_TIME = curr_time;
        end;
    end;

    # Read the data if artifact name is within the library
    if arttag in YAML_TAGS
        # Download the artifact dataset (or return cached path)
        fileloc = download_dataset!(arttag);
        if isfile(fileloc)
            # Read data based on cycle number
            # Note: read_dataset does not support interpolation parameter directly
            # It only supports read_std parameter (not include_std)
            if cyc < 1
                data = read_dataset(fileloc, lat, lon);
                std = include_std ? read_dataset(fileloc, lat, lon; read_std = true) : nothing;
            else
                data = read_dataset(fileloc, lat, lon, cyc);
                std = include_std ? read_dataset(fileloc, lat, lon, cyc; read_std = true) : nothing;
            end;

            # Filter the data: replace NaN with -9999 for JSON compatibility
            if typeof(data) <: Array
                data[isnan.(data)] .= -9999;
            elseif typeof(data) <: Number
                if isnan(data) data = -9999; end;
            end;

            # Filter std if it exists (std could be nothing if not available in dataset)
            if include_std && !isnothing(std)
                if typeof(std) <: Array
                    std[isnan.(std)] .= -9999;
                elseif typeof(std) <: Number
                    if isnan(std) std = -9999; end;
                end;
            end;

            # Prepare the response dictionary
            json_dict = Dict{String,Any}(
                "Note 1"          => "Unregistered users need to wait for 2 seconds to avoid malicious attack. Please contact authors of GriddingMachine.jl for registration.",
                "Note 2"          => "NaN or missing values are replaced with -9999",
                "User"            => user,
                "Latitude"        => lat,
                "Longitude"       => lon,
                "Cycle"           => cyc,
                "Result"          => data,
            );
            if include_std
                # Add std to response (could be nothing if not available in dataset)
                json_dict["Stdv"] = isnothing(std) ? "Not available in dataset" : std;
            end;

            return GRJSON.json(json_dict)
        end;
    end;

    # If not in collection, return a warning
    json_warn = Dict{String,Any}(
        "Note"            => "Unregistered users need to wait for 2 seconds to avoid malicious attack.",
        "Warning"         => "Your request cannot be completed, please check your settings",
        "User"            => user,
        "Latitude"        => lat,
        "Longitude"       => lon,
        "Cycle"           => cyc,
    );

    return GRJSON.json(json_warn)
end;
