#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: add function request_GMDICT
#
#######################################################################################################################################################################################################
"""

    request_GMDICT(
                gmversion::String,
                year::Int,
                lat::Number,
                lon::Number;
                port::Int = 5055,
                server::String = "http://tropo.gps.caltech.edu",
                user::String="Anonymous")

Request Emerald data from the server, given
- `gmversion` Emerald version such as `gm2`
- `year` Year
- `lat` Latitude
- `lon` Longitude
- `port` Port number for the GriddingMachine server
- `server` Server address such as `https://tropo.gps.caltech.edu`
- `user` User name (non-registered users need to wait for 5 seconds before the server processes the request)

---
# Examples
```julia
gmdict = request_GMDICT("gm2", 2019, 30.5, 115.5);
```

"""
function request_GMDICT(
            gmversion::String,
            year::Int,
            lat::Number,
            lon::Number;
            port::Int = 5055,
            server::String = "http://tropo.gps.caltech.edu",
            user::String="Anonymous")
    # send a request to our webserver at tropo.gps.caltech.edu:44301 and translate it back to Dictionary
    web_url = "$(server):$(port)/gmdict.json?user=$(user)&gmversion=$(gmversion)&year=$(year)&lat=$(lat)&lon=$(lon)";
    web_response = get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = parse(json_str);

    # if there is no result item in the Dictionary
    if !haskey(json_dict, "GM Dict")
        @show json_dict;
        return error("There is something wrong with the request, please check the details about it!");
    end;

    # return the GM Dict
    return json_dict["GM Dict"]
end;
