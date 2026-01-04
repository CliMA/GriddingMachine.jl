# ======================================================================================
# Route Setup Functions for GriddingMachine Server
# ======================================================================================
#
# This file contains route setup functions that configure URL endpoints for the server.
# Routes can be set up with or without user authentication.
#

"""

    setup_url_input_routes!(allowed_users::Vector{String})

Set up URL input routes with user authentication. Only users in the allowed_users list can access these routes, given
- `allowed_users` Vector of allowed user names

Available routes:
- `/sitedata.json` - Legacy route for site data requests (uses sitedata_json function)

"""
function setup_url_input_routes!(allowed_users::Vector{String})
    # Display the allowed users for this local server
    println("The url-input server is meant for users: ", join(allowed_users, ", "));

    # Legacy route for sitedata request (backward compatibility)
    route("/sitedata.json") do
        user = params(:user, "Anonymous");
        arttag = params(:tag, "LM_4X_1Y_V1");
        lat = parse(Float64, params(:lat, "30.5"));
        lon = parse(Float64, params(:lon, "115.5"));
        cyc = parse(Int, params(:cycle, "0"));

        @info "Received a direct sitedata request from $(user) for $(arttag) at lat: $(lat), lon: $(lon)!";

        if user in allowed_users
            return sitedata_json(arttag, lat, lon, cyc)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    # Main artifact data request route
    route("/request.json") do
        user = params(:user, "Anonymous");
        arttag = params(:artifact, "Missing");
        lat = parse(Float64, params(:lat, "30.5"));
        lon = parse(Float64, params(:lon, "115.0"));
        cyc = parse(Int, params(:cyc, "0"));
        include_std = parse(Bool, params(:include_std, "true"));

        @info "Received a direct URL request from $(user) for $(arttag) at lat: $(lat), lon: $(lon)!";

        if user in allowed_users
            return artifact_json(user, arttag, lat, lon, cyc; include_std = include_std)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    # Alias for request.json
    route("/artifact.json") do
        user = params(:user, "Anonymous");
        arttag = params(:artifact, "Missing");
        lat = parse(Float64, params(:lat, "30.5"));
        lon = parse(Float64, params(:lon, "115.0"));
        cyc = parse(Int, params(:cyc, "0"));
        include_std = parse(Bool, params(:include_std, "true"));

        @info "Received an artifact request from $(user) for $(arttag) at lat: $(lat), lon: $(lon)!";

        if user in allowed_users
            return artifact_json(user, arttag, lat, lon, cyc; include_std = include_std)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    # GM Dictionary route
    route("/gmdict.json") do
        user = params(:user, "Anonymous");
        gmversion = params(:gmversion, "gm2");
        year = parse(Int, params(:year, "2019"));
        lat = parse(Float64, params(:lat, "35.5"));
        lon = parse(Float64, params(:lon, "115.5"));

        @info "Received a gmdict request from $(user) for $(gmversion) year $(year) at lat: $(lat), lon: $(lon)!";
        if user in allowed_users
            return gmdict_json(user, gmversion, year, lat, lon)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    # Weather data route
    route("/weather.json") do
        user = params(:user, "Anonymous");
        wdversion = params(:wdversion, "wd1");
        year = parse(Int, params(:year, "2019"));
        lat = parse(Float64, params(:lat, "35.5"));
        lon = parse(Float64, params(:lon, "115.5"));

        @info "Received a weather request from $(user) for $(wdversion) year $(year) at lat: $(lat), lon: $(lon)!";
        if user in allowed_users
            return weather_json(user, wdversion, year, lat, lon)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    # ===================================================================================
    # Web Interface Routes (HTML forms and results)
    # ===================================================================================

    # Unified form selector (homepage) - Dynamic interface with tabs
    route("/") do
        # Generate dynamic artifact tag options
        tag_options = join(["""<option>$(t)</option>""" for t in GM_TAGS], "\n")

        # Replace placeholder in UNIFIED_FORM with actual tag options
        html_content = replace(UNIFIED_FORM,
            """<option>--Choose a TAG--</option>\n                    <!-- Tags will be populated by Julia -->""" =>
            """<option>--Choose a TAG--</option>\n                    $(tag_options)"""
        )

        return html_content
    end;

    # Individual form display routes (for backward compatibility)
    route("/gm_artifact_form") do
        return ARTIFACT_FORM
    end;

    route("/gm_dict_form") do
        return GMDICT_FORM
    end;

    route("/gm_weather_form") do
        return WEATHER_FORM
    end;

    # Form result processing routes
    route("/gm_artifact_result", method = "POST") do
        postkeys = keys(postpayload());

        arttag = postpayload(:tag);
        lat = parse(Float64, postpayload(:lat));
        lon = parse(Float64, postpayload(:lon));
        cyc = parse(Int, postpayload(:cyc));

        # Handle checkbox parameters (present when checked, absent when unchecked)
        include_std = :include_std in postkeys;

        @info "Received a WEB request for $(arttag) at lat: $(lat), lon: $(lon)!";
        
        return artifact_json("Anonymous", arttag, lat, lon, cyc; include_std = include_std)

    end;

    route("/gm_dict_result", method = "POST") do
        gmversion = postpayload(:gmv);
        year = parse(Int, postpayload(:year));
        lat = parse(Float64, postpayload(:lat));
        lon = parse(Float64, postpayload(:lon));

        @info "Received a WEB gmdict request for $(gmversion) year $(year) at lat: $(lat), lon: $(lon)!";
        
        return gmdict_json("Anonymous", gmversion, year, lat, lon)
    end;

    route("/gm_weather_result", method = "POST") do
        wdversion = postpayload(:wdv);
        year = parse(Int, postpayload(:year));
        lat = parse(Float64, postpayload(:lat));
        lon = parse(Float64, postpayload(:lon));

        @info "Received a WEB weather request for $(wdversion) year $(year) at lat: $(lat), lon: $(lon)!";
        
        return weather_json("Anonymous", wdversion, year, lat, lon)
    end;

    return nothing
end;
