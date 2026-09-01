"""Weather driver collections this endpoint accepts."""
const SUPPORTED_WD_VERSIONS = ("wd1",)

"""

    weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)

Return an HTTP response whose body is the JSON-encoded weather driver series for one grid
cell, given
- `user` free-form label echoed back and logged; not an access control mechanism
- `wdversion` weather driver collection, one of `SUPPORTED_WD_VERSIONS`
- `year` year of the weather series
- `lat` the target latitude
- `lon` the target longitude

Missing values are encoded as -9999. The weather products are large and are commonly absent
from a local catalog, so an incomplete catalog produces a response that names every missing
tag rather than an exception.
"""
function weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)
    context = OrderedDict{String,Any}(
        "User" => user,
        "WDVersion" => wdversion,
        "Year" => year,
        "Latitude" => lat,
        "Longitude" => lon,
    )

    wdversion in SUPPORTED_WD_VERSIONS ||
        return GRJSON.json(warning_payload(REASON_UNSUPPORTED, context))

    labels = WeatherDriverLabels(wdversion, year)
    absent = missing_tags(required_tags(labels))
    isempty(absent) || return GRJSON.json(missing_datasets_payload(absent, context))

    wd_dict = try
        grid_weather(labels, lat, lon)
    catch exception
        @error "weather request failed" user wdversion year lat lon exception
        return GRJSON.json(warning_payload(classify_error(exception), context))
    end

    payload = OrderedDict{String,Any}(context)
    payload["WeatherDrivers"] = OrderedDict{String,Any}(
        String(key) => encode_missing(value) for (key, value) in wd_dict
    )

    return GRJSON.json(payload)
end;
