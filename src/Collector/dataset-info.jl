""" Return the cache dataset file path for a given artifact tag """
function dataset_cache(arttag::String)
    if !dataset_found(arttag)
        return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
    end;

    return joinpath(GRIDDINGMACHINE_HOME, "cache", "$(arttag).nc")
end;


""" Return the dataset directory for a given artifact tag """
function dataset_dir(arttag::String)
    if !dataset_found(arttag)
        return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
    end;

    art_dir = joinpath(GRIDDINGMACHINE_HOME, YAML_DATABASE[arttag]["PATH"]);
    if !ispath(art_dir)
        mkpath(art_dir);
    end;

    return art_dir
end;


""" Return whether the dataset exists in the database """
function dataset_found(arttag::String)
    return arttag in YAML_TAGS
end;


""" Return the dataset file path for a given artifact tag """
function dataset_path(arttag::String)
    if !dataset_found(arttag)
        return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
    end;

    return joinpath(GRIDDINGMACHINE_HOME, YAML_DATABASE[arttag]["PATH"], "$(arttag).nc")
end;


""" Return the dataset download URL for a given artifact tag """
function dataset_url(arttag::String)
    if !dataset_found(arttag)
        return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
    end;

    return YAML_DATABASE[arttag]["URL"]
end;
