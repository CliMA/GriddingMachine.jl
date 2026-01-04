"""

    url_json(arttag::String)

Generate a JSON string containing download URL, folder path, and SHA checksum for a given artifact tag, given
- `arttag` Artifact tag (e.g., "CH_2X_1Y_V2")

"""
function url_json(arttag::String)
    # Get artifact metadata from YAML database
    art_info = YAML_DATABASE[arttag];

    # Extract folder path
    art_folder = art_info["FOLDER"];

    # Construct complete FTP download URL
    art_url = joinpath("ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/tarballs", art_folder, "$(arttag).tar.gz");

    # Return JSON with download information
    return GRJSON.json(Dict{String,String}(
        "url" => art_url,
        "folder" => art_info["FOLDER"],
        "sha" => art_info["SHA"]
    ))
end;


"""

    artifact_url_json(arttag::String)

Check artifact tag validity, update database if necessary, and return download information or error message as JSON, given
- `arttag` Artifact tag (e.g., "CH_2X_1Y_V2")

"""
function artifact_url_json(arttag::String)
    global YAML_FILE_TIME;

    # First check: if arttag exists in database, return download info immediately
    if arttag in YAML_TAGS
        return url_json(arttag)
    end;

    # If arttag not found, check if database needs updating (rate limited to once per 60 seconds)
    curr_time = now();
    dtime = seconds(curr_time - YAML_FILE_TIME);
    if dtime > 60
        update_database!();
        YAML_FILE_TIME = curr_time;
    end;

    # Second check: re-check after database update
    if arttag in YAML_TAGS
        return url_json(arttag)
    end;

    # If still not found, return error message
    return GRJSON.json(Dict{String,String}("error" => "Provided TAG is not supported!"))
end;
