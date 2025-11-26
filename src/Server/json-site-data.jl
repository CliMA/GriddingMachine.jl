"""

    sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int)

Return a JSON string containing the specified artifact data for the given location, given
- `arttag` the artifact tag (e.g., "CH_2X_1Y_V2")
- `lat` the target latitude
- `lon` the target longitude
- `cyc` the data cycle number (0 for all cycles)

"""
function sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int)
    # if the arttag does not exist in current database, update the database
    if !(arttag in YAML_TAGS)
        update_database!();
    end;

    # read the data if artifact name is within the libarary
    if arttag in YAML_TAGS
        # downlad the dataset
        fpath = download_dataset!(arttag);
        if isfile(fpath)
            # if cyc = 0, read all cycles, convert NaN to -9999
            if cyc == 0
                data = read_dataset(fpath, lat, lon);
                stdv = read_dataset(fpath, lat, lon; read_std = true);
                if typeof(data) <: Number
                    data = isnan(data) ? -9999 : data;
                    stdv = isnan(stdv) ? -9999 : stdv;
                else
                    data = replace(data, NaN => -9999);
                    stdv = replace(stdv, NaN => -9999);
                end;
            else
                data = read_dataset(fpath, lat, lon, cyc);
                stdv = read_dataset(fpath, lat, lon, cyc; read_std = true);
                data = isnan(data) ? -9999 : data;
                stdv = isnan(stdv) ? -9999 : stdv;
            end;

            # prepare the dict
            json_dict = Dict{String,Any}(
                "Latitude"  => lat,
                "Longitude" => lon,
                "Cycle"     => cyc,
                "Data"      => data,
                "Stdv"      => stdv,
                "Nothing"   => nothing,
            );

            # return a JSON string
            return GRJSON.json(json_dict)
        end;
    end;

    # if not in collection, return an warning
    json_warn = Dict{String,Any}(
        "Warning"   => "Your request cannot be completed, please check your settings",
        "Latitude"  => lat,
        "Longitude" => lon,
        "Cycle"     => cyc,
    );

    return GRJSON.json(json_warn)
end;
