"""Read the required `lat` and `lon` query parameters, or `nothing` when either is unusable."""
function _requested_point()
    lat = parse_coordinate(params(:lat, ""));
    lon = parse_coordinate(params(:lon, ""));

    return (isnothing(lat) || isnothing(lon)) ? nothing : (lat, lon)
end;

"""Failure response for a request that did not carry a usable pair of coordinates.

Echoes back what arrived so the caller can see which field was rejected.
"""
function _missing_point(user::String)
    context = OrderedDict{String,Any}(
        "User" => user,
        "Latitude" => String(params(:lat, "")),
        "Longitude" => String(params(:lon, "")),
        "Hint" => "lat and lon are required and must be numbers",
    );

    return GRJSON.json(warning_payload(REASON_MISSING_COORDINATES, context))
end;

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

`lat` and `lon` are required on every query endpoint. Optional settings such as `cycle` or
`include_std` fall back to a default when they are missing or malformed, but coordinates never
do: answering for a different grid cell than the caller asked about would be worse than
refusing the request.
"""
function setup_url_input_routes!(allowed_users::Vector{String} = String[])
    isempty(allowed_users) ||
        @info "Server labels requests for: $(join(allowed_users, ", ")) (labels only, not access control)";

    route("/sitedata.json") do
        user = String(params(:user, "anonymous"));
        arttag = String(params(:tag, ""));
        cyc = parse_int(params(:cycle, ""), 0);
        include_std = parse_bool(params(:include_std, ""), true);
        point = _requested_point();

        @info "sitedata request" user arttag point cyc include_std;

        isnothing(point) && return _missing_point(user);
        lat, lon = point;

        return sitedata_json(arttag, lat, lon, cyc; include_std)
    end;

    route("/gmdict.json") do
        user = String(params(:user, "anonymous"));
        gmversion = String(params(:gmversion, "gm2"));
        year = parse_int(params(:year, ""), 2020);
        point = _requested_point();

        @info "gmdict request" user gmversion year point;

        isnothing(point) && return _missing_point(user);
        lat, lon = point;

        return gmdict_json(user, gmversion, year, lat, lon)
    end;

    route("/weather.json") do
        user = String(params(:user, "anonymous"));
        wdversion = String(params(:wdversion, "wd1"));
        year = parse_int(params(:year, ""), 2020);
        point = _requested_point();

        @info "weather request" user wdversion year point;

        isnothing(point) && return _missing_point(user);
        lat, lon = point;

        return weather_json(user, wdversion, year, lat, lon)
    end;

    route("/") do
        return query_page()
    end;

    return nothing
end;
