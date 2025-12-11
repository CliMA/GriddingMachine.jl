""" Download the dataset file for a given artifact tag """
function download_dataset!(arttag::String)
    # If dataset not found in the database, update the database. If still not found, return an error
    if !dataset_found(arttag)
        update_database!();
        if !dataset_found(arttag)
            return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
        end;
    end;

    # if the dataset file already exists, return the path directly
    dataset_file = dataset_path(arttag);
    if isfile(dataset_file)
        return dataset_file
    end;

    # download the dataset directly from the URL of the associated dataset
    @info "Downloading dataset for $arttag from $(dataset_url(arttag))...";
    cache_file = dataset_cache(arttag);
    urls = dataset_url(arttag);
    for url in urls
        try
            Downloads.download(url, cache_file);
            break;
        catch e
            @warn "Failed to download from $url"
            continue;
        end;
    end;
    mkpath(dataset_dir(arttag));
    mv(cache_file, dataset_file);

    return dataset_file
end;
