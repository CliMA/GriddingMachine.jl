"""

    setup_url_input_routes!(allowed_users::Vector{String} = String[])

Register the query endpoints and the query page.

`allowed_users` is retained for backward compatibility and is used only for the startup log
line. The `user` query parameter is a free-form label written to the request log, not a
credential: it arrives from the query string and any caller can set it to any value. This
server is meant for a local or trusted intranet network.

Registered routes:
- `/sitedata.json` one dataset value at one grid cell
- `/gmdict.json` land parameter dictionary at one grid cell
- `/weather.json` weather driver series at one grid cell
- `/` the query page
"""
function setup_url_input_routes!(allowed_users::Vector{String} = String[])
    isempty(allowed_users) ||
        @info "Server labels requests for: $(join(allowed_users, ", ")) (labels only, not access control)";

    route("/sitedata.json") do
        user = String(params(:user, "anonymous"));
        arttag = String(params(:tag, ""));
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);
        cyc = parse_int(params(:cycle, ""), 0);
        include_std = parse_bool(params(:include_std, ""), true);

        @info "sitedata request" user arttag lat lon cyc include_std;

        return sitedata_json(arttag, lat, lon, cyc; include_std)
    end;

    route("/gmdict.json") do
        user = String(params(:user, "anonymous"));
        gmversion = String(params(:gmversion, "gm2"));
        year = parse_int(params(:year, ""), 2020);
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);

        @info "gmdict request" user gmversion year lat lon;

        return gmdict_json(user, gmversion, year, lat, lon)
    end;

    route("/weather.json") do
        user = String(params(:user, "anonymous"));
        wdversion = String(params(:wdversion, "wd1"));
        year = parse_int(params(:year, ""), 2020);
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);

        @info "weather request" user wdversion year lat lon;

        return weather_json(user, wdversion, year, lat, lon)
    end;

    route("/") do
        return query_page()
    end;

    return nothing
end;
