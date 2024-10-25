#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Aug-06: add include_std option
#
#######################################################################################################################################################################################################
"""

    request_LUT(artname::String,
                lat::Number,
                lon::Number,
                cyc::Int = 0;
                include_std::Bool = false,
                interpolation::Bool = false,
                port::Int = 5055,
                server::String = "http://tropo.gps.caltech.edu",
                user::String="Anonymous")

Request data from the server, given
- `artname` Artifact full name such as `LAI_MODIS_2X_8D_2017_V1`
- `lat` Latitude
- `lon` Longitude
- `cyc` Cycle index, default is 0 (read entire time series)
- `include_std` If true, include the standard deviation
- `interpolation` If true, interpolate the data linearly
- `port` Port number for the GriddingMachine server
- `server` Server address such as `https://tropo.gps.caltech.edu`
- `user` User name (non-registered users need to wait for 5 seconds before the server processes the request)

---
# Examples
```julia
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true);
```

"""
function request_LUT(
            artname::String,
            lat::Number,
            lon::Number,
            cyc::Int = 0;
            include_std::Bool = false,
            interpolation::Bool = false,
            port::Int = 5055,
            server::String = "http://tropo.gps.caltech.edu",
            user::String="Anonymous")
    @assert artname in META_TAGS "$(artname) not found in Artifacts.toml";

    # send a request to our webserver at tropo.gps.caltech.edu:44301 and translate it back to Dictionary
    web_url = "$(server):$(port)/request.json?user=$(user)&artifact=$(artname)&lat=$(lat)&lon=$(lon)&cyc=$(cyc)&interpolate=$(interpolation)&include_std=$(include_std)";
    web_response = get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = parse(json_str);

    # if there is no result item in the Dictionary
    if !haskey(json_dict, "Result")
        @show json_dict;
        return error("There is something wrong with the request, please check the details about it!")
    end;

    # replace -9999 with NaN
    data = json_dict["Result"];
    if typeof(data) <: Array
        data[data .== -9999] .= NaN;
    else
        if data == -9999 data = NaN; end;
    end;
    if include_std
        std = json_dict["Error"];
        if typeof(data) <: Array
            std[std .== -9999] .= NaN;
        else
            if std == -9999 std = NaN; end;
        end;
    end;

    # if length of data is 1 return a Number, else return a Vector
    if length(data) > 1
        return include_std ? (Float32.(data), Float32.(std)) : Float32.(data)
    else
        return include_std ? (Float32(data[1]), Float32(std[1])) : Float32(data[1])
    end;
end;
