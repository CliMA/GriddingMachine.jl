"""

    request_site_data(server::String, user::String, tag::String, lat::Number, lon::Number, cycle::Int = 0)

Send a request to the specified server to get the artifact data for the given location, given
- `server` the server URL (e.g., "http://localhost:8000")
- `user` the user name
- `tag` the artifact tag (e.g., "LM_4X_1Y_V1")
- `lat` the target latitude
- `lon` the target longitude
- `cycle` the data cycle number (0 for all cycles, default is 0)

"""
function request_site_data(server::String, user::String, tag::String, lat::Number, lon::Number, cycle::Int = 0)
    # send a request to the server and translate it back to Dictionary
    web_url = "$(server)/sitedata.json?user=$(user)&tag=$(tag)&lat=$(lat)&lon=$(lon)&cycle=$(cycle)";
    web_response = HTTP.get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = JSON.parse(json_str);

    # if there is no result item in the Dictionary
    if !haskey(json_dict, "Data")
        return error("There is something wrong with the request, please check the details about it!")
    end;

    # convert -9999 back to NaN for data
    if typeof(json_dict["Data"]) <: Number
        json_dict["Data"] = (json_dict["Data"] == -9999) ? NaN : json_dict["Data"];
    elseif typeof(json_dict["Data"]) <: Vector
        json_dict["Data"] = replace(json_dict["Data"], -9999 => NaN);
    end;

    # convert -9999 back to NaN for stdv (may be nothing, so do not convert it along with data)
    if typeof(json_dict["Stdv"]) <: Number
        json_dict["Stdv"] = (json_dict["Stdv"] == -9999) ? NaN : json_dict["Stdv"];
    elseif typeof(json_dict["Stdv"]) <: Vector
        json_dict["Stdv"] = replace(json_dict["Stdv"], -9999 => NaN);
    end;

    return json_dict["Data"], json_dict["Stdv"]
end;
