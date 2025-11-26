function setup_url_input_routes!(allowed_users::Vector{String})
    # display the allowed users for this local server
    println("The url-input server is meant for users: ", join(allowed_users, ", "));

    #
    #
    # set up the route for sitedata request
    #
    #
    route("/sitedata.json") do
        user = params(:user, "Anonymous");
        arttag = params(:tag, "LM_4X_1Y_V1");
        lat = parse(Float64, params(:lat, "30.5"));
        lon = parse(Float64, params(:lon, "115.5"));
        cyc = parse(Int, params(:cycle, "0"));

        @info "Recieved a direct sitedata request from $(user) for $(arttag) at lat: $(lat), lon: $(lon)!";

        if user in allowed_users
            return sitedata_json(arttag, lat, lon, cyc)
        end;

        return GRJSON.json(Dict("Error" => "This website is not meant for public use!"))
    end;

    return nothing
end;
