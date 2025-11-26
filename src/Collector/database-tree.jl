""" Return a list of the path of latest datasets in the GriddingMachine.jl database (if downloaded) """
function latest_datasets()
    file_list = String[];
    for arttag in YAML_TAGS
        push!(file_list, dataset_path(arttag));
    end;

    return file_list
end;


""" Return a list of all local datasets in the GriddingMachine.jl database """
function local_datasets()
    # return all available dataset arttags
    public_dir = joinpath(GRIDDINGMACHINE_HOME, "public");

    return files_in_folder(public_dir)
end;


""" Return a list of all files in a given folder (including subfolders) """
function files_in_folder(folder::String)
    file_list = String[];
    paths = readdir(folder; join = true);

    for p in paths
        if isfile(p)
            push!(file_list, p);
        elseif isdir(p)
            append!(file_list, files_in_folder(p));
        end;
    end;

    return file_list
end;
