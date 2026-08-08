function latest_datasets()
    _ensure_database_loaded!()
    return [dataset_path(arttag) for arttag in YAML_TAGS]
end

function local_datasets()
    initialize_database!()
    return files_in_folder(joinpath(GRIDDINGMACHINE_HOME, "public"))
end

function files_in_folder(folder::String)
    isdir(folder) || return String[]
    file_list = String[]
    for path in readdir(folder; join = true)
        isfile(path) ? push!(file_list, path) : isdir(path) && append!(file_list, files_in_folder(path))
    end
    return file_list
end
