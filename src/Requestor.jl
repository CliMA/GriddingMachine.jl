module Requestor

using Artifacts: load_artifacts_toml
using DocStringExtensions: METHODLIST
using HTTP: get
using JSON: parse
using PkgUtility: terror

export request_LUT


"""
This function requests data from our server for supported datasets (only latest datasets supported). Supported methods are

$(METHODLIST)
"""
function request_LUT end;


"""
    request_LUT(artname::String, lat::Number, lon::Number, cyc::Int = 0; user::String="Anonymous", interpolation::Bool = false, server::String = "griddingmachine.myftp.org", port::Int = 5055)

Request data from the server, given
- `artname` Artifact full name such as `LAI_MODIS_2X_8D_2017_V1`
- `lat` Latitude
- `lon` Longitude
- `cyc` Cycle index, default is 0 (read entire time series)
- `user` User name (non-registered users need to wait for 5 seconds before the server processes the request)
- `interpolation` If true, interpolate the data linearly
- `server` Server address
- `port` Port number for the GriddingMachine server

---
# Examples
```julia
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8);
request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true);
```
"""
request_LUT(artname::String, lat::Number, lon::Number, cyc::Int = 0; user::String="Anonymous", interpolation::Bool = false, server::String = "griddingmachine.myftp.org", port::Int = 5055) = (
    # make sure the artifact is within our collection
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _artns = [_name for (_name,_) in _metas];
    @assert artname in _artns;

    # send a request to our webserver at tofu.gps.caltech.edu:5055 and translate it back to Dictionary
    _response = get("http://$(server):$(port)/request.json?user=$(user)&artifact=$(artname)&lat=$(lat)&lon=$(lon)&cyc=$(cyc)&interpolate=$(interpolation)");
    _json_str = String(_response.body);
    _results  = parse(_json_str);

    # if there is no result item in the Dictionary
    if !haskey(_results, "Result")
        @show _results;
        @error terror("There is something wrong with the request, please check the details about it!");
    end;

    # replace -9999 to NaN
    _data = _results["Result"];
    _std = _results["Error"];
    if typeof(_data) <: Array
        _data[_data .== -9999] .= NaN;
        _std[_std .== -9999] .= NaN;
    else
        if _data == -9999 _data = NaN; end;
        if _std == -9999 _std = NaN; end;
    end;

    # if length of data is 1 return a Number, else return a Vector
    if length(_data) > 1
        return Float32.(_data), Float32.(_data)
    end;

    return Float32(_data[1]), Float32(_std[1])
);


end
