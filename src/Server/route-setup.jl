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
    # TODO:强制用户校验
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


    return nothing
end;


"""

    setup_public_routes!()

Set up public routes accessible without authentication. These routes provide the main API for GriddingMachine data access.

Available API routes:
- `/request.json` - Request artifact data with interpolation and std options
- `/artifact.json` - Alias for /request.json
- `/url.json` - Get download URL for an artifact
- `/gmdict.json` - Request GriddingMachine dictionary data
- `/weather.json` - Request weather driver data (requires Emerald)

Available web interface routes:
- `/` - Unified form selector (homepage)
- `/gm_artifact_form` - Artifact data request form
- `/gm_dict_form` - GM dictionary request form
- `/gm_weather_form` - Weather data request form
- `/gm_artifact_result` - Process artifact form submission
- `/gm_dict_result` - Process GM dictionary form submission
- `/gm_weather_result` - Process weather form submission

"""
function setup_public_routes!()
    println("Setting up public routes for GriddingMachine server...");

    # ===================================================================================
    # API Routes (JSON responses)
    # ===================================================================================

    # Main artifact data request route
    route("/request.json") do
        user = params(:user, "Anonymous");
        arttag = params(:artifact, "Missing");
        lat = parse(Float64, params(:lat, "30.5"));
        lon = parse(Float64, params(:lon, "115.0"));
        cyc = parse(Int, params(:cyc, "0"));
        include_std = parse(Bool, params(:include_std, "true"));

        @info "Received a direct URL request from $(user) for $(arttag) at lat: $(lat), lon: $(lon)!";

        return artifact_json(user, arttag, lat, lon, cyc; include_std = include_std)
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

        return artifact_json(user, arttag, lat, lon, cyc; include_std = include_std)
    end;

    # Artifact URL route (get download URL)
    route("/url.json") do
        arttag = params(:artifact, "Missing");

        @info "Received a URL request for artifact: $(arttag)";

        return artifact_url_json(arttag)
    end;

    # GM Dictionary route
    route("/gmdict.json") do
        user = params(:user, "Anonymous");
        gmversion = params(:gmversion, "gm2");
        year = parse(Int, params(:year, "2019"));
        lat = parse(Float64, params(:lat, "35.5"));
        lon = parse(Float64, params(:lon, "115.5"));

        @info "Received a gmdict request from $(user) for $(gmversion) year $(year) at lat: $(lat), lon: $(lon)!";

        return gmdict_json(user, gmversion, year, lat, lon)
    end;

    # Weather data route
    route("/weather.json") do
        user = params(:user, "Anonymous");
        wdversion = params(:wdversion, "wd1");
        gmversion = params(:gmversion, "gm2");
        year = parse(Int, params(:year, "2019"));
        lat = parse(Float64, params(:lat, "35.5"));
        lon = parse(Float64, params(:lon, "115.5"));

        @info "Received a weather request from $(user) for $(wdversion)/$(gmversion) year $(year) at lat: $(lat), lon: $(lon)!";

        return weather_json(user, wdversion, gmversion, year, lat, lon)
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
        gmversion = postpayload(:gmv);
        year = parse(Int, postpayload(:year));
        lat = parse(Float64, postpayload(:lat));
        lon = parse(Float64, postpayload(:lon));

        @info "Received a WEB weather request for $(wdversion)/$(gmversion) year $(year) at lat: $(lat), lon: $(lon)!";

        return weather_json("Anonymous", wdversion, gmversion, year, lat, lon)
    end;

    return nothing
end;
