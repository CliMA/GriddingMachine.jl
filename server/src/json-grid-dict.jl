"""Land parameter collections this endpoint accepts."""
const SUPPORTED_GM_VERSIONS = ("gm1", "gm2")

"""

    gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)

Return an HTTP response whose body is the JSON-encoded land parameter dictionary for one
grid cell, given
- `user` free-form label echoed back and logged; not an access control mechanism
- `gmversion` land parameter collection, one of `SUPPORTED_GM_VERSIONS`
- `year` year selecting the time dependent products
- `lat` the target latitude
- `lon` the target longitude

Missing values are encoded as -9999. When a required dataset is absent from the local
catalog the response lists the missing tags instead of raising, and no remote catalog
refresh is triggered: downloading is the responsibility of `Collector`.
"""
function gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)
    context = OrderedDict{String,Any}(
        "User" => user,
        "GMVersion" => gmversion,
        "Year" => year,
        "Latitude" => lat,
        "Longitude" => lon,
    )

    gmversion in SUPPORTED_GM_VERSIONS ||
        return GRJSON.json(warning_payload(REASON_UNSUPPORTED, context))

    labels = LandDatasetLabels(gmversion, year)
    absent = missing_tags(required_tags(labels))
    isempty(absent) || return GRJSON.json(missing_datasets_payload(absent, context))

    gm_dict = try
        grid_dict(labels, lat, lon)
    catch exception
        @error "gmdict request failed" user gmversion year lat lon exception
        return GRJSON.json(warning_payload(classify_error(exception), context))
    end

    payload = OrderedDict{String,Any}(context)
    payload["GridDict"] = OrderedDict{String,Any}(
        String(key) => encode_missing(value) for (key, value) in gm_dict
    )

    return GRJSON.json(payload)
end;
