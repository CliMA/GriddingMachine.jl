"""

    clean_database!(selection::String = "old") :: Nothing
    clean_database!(arttags::Vector{String}) :: Nothing

Cleans up the local database of datasets by removing old or specified datasets, given
- `selection` old (default) or all
- `arttags` a Vector of tags

"""
function clean_database! end

clean_database!(selection::String = "old") :: Nothing = (
    # iterate through the artifacts and remove the old one that is not in current Artifacts.toml or remove all artifacts within GriddingMachine.jl
    public_dir = joinpath(GRIDDINGMACHINE_HOME, "public");
    sub_dirs = readdir(public_dir);

    # if remove all artifacts
    if selection == "all"
        for fn in sub_dirs
            rm(joinpath(public_dir, fn); recursive=true, force=true);
        end;

        return nothing
    end;

    # otherwise, remove the old artifacts (update database first)
    if selection == "old"
        update_database!();
        latest_dataset_paths = latest_datasets();
        local_dataset_paths = local_datasets();
        outdated_paths = setdiff(local_dataset_paths, latest_dataset_paths);
        for p in outdated_paths
            @show p;
            # rm(p; recursive=true, force=true);
        end;
    end;

    return nothing
);

clean_database!(arttags::Vector{String}) :: Nothing = (
    # iterate the artifact hashs to remove corresponding folder
    for arttag in arttags
        rm(dataset_cache(arttag); recursive = true, force = true);
        rm(dataset_path(arttag); recursive = true, force = true);
    end;

    return nothing
);
