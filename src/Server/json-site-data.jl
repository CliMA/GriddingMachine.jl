"""

    sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)

Return an HTTP response whose body is the JSON-encoded dataset value at one grid cell, given
- `arttag` the dataset tag (e.g., "CH_2X_1Y_V2")
- `lat` the target latitude
- `lon` the target longitude
- `cyc` the cycle number (0 reads every cycle)
- `include_std` whether to report the error variable (default `true`)

Missing values are encoded as -9999 because JSON has no NaN literal;
`Requestor.request_site_data` converts them back to NaN.

When `include_std` is `false` the `Stdv` key is set to `null` rather than removed, because
`Requestor.request_site_data` reads that key unconditionally.

An unknown tag is reported as a warning without refreshing the catalog. Refreshing on every
unknown tag means a single typo against a catalog of over a thousand entries re-downloads the
whole catalog before answering; use `Collector.update_database!` to pick up new publications.
"""
function sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)
    # dataset_found loads the catalog if this process has not read it yet
    if dataset_found(arttag)
        fpath = download_dataset!(arttag);
        if isfile(fpath)
            if cyc == 0
                data = read_dataset(fpath, lat, lon);
                stdv = include_std ? read_dataset(fpath, lat, lon; read_std = true) : nothing;
            else
                data = read_dataset(fpath, lat, lon, cyc);
                stdv = include_std ? read_dataset(fpath, lat, lon, cyc; read_std = true) : nothing;
            end;

            json_dict = OrderedDict{String,Any}(
                "Latitude"  => lat,
                "Longitude" => lon,
                "Cycle"     => cyc,
                "Data"      => encode_missing(data),
                "Stdv"      => encode_missing(stdv),
            );

            return GRJSON.json(json_dict)
        end;
    end;

    json_warn = OrderedDict{String,Any}(
        "Warning"   => "Your request cannot be completed, please check your settings",
        "Latitude"  => lat,
        "Longitude" => lon,
        "Cycle"     => cyc,
    );

    return GRJSON.json(json_warn)
end;
