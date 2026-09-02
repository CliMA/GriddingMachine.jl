function _assert_managed_path(path::AbstractString)
    managed_root = abspath(GRIDDINGMACHINE_HOME)
    resolved = abspath(path)
    relative = relpath(resolved, managed_root)
    (relative == "." || isabspath(relative) || first(splitpath(relative)) == "..") &&
        error("Refusing to remove unmanaged path: $resolved")
    return resolved
end

"""Remove old or all downloaded datasets under the configured isolated data root.

Removing a dataset leaves the directory that held it behind, so the directories that end up
empty are removed as well. `public` itself is kept.
"""
function clean_database!(selection::String = "old"; update::Bool = false)
    selection in ("old", "all") || throw(ArgumentError("selection must be 'old' or 'all'"))
    initialize_database!()
    public_dir = joinpath(GRIDDINGMACHINE_HOME, "public")

    if selection == "all"
        # every child is removed recursively, so nothing empty is left to tidy up
        for path in readdir(public_dir; join = true)
            rm(_assert_managed_path(path); recursive = true, force = true)
        end
        return nothing
    end

    update ? update_database!() : _ensure_database_loaded!()
    expected = Set(abspath.(latest_datasets()))
    for path in local_datasets()
        abspath(path) in expected || rm(_assert_managed_path(path); force = true)
    end
    remove_empty_folders!(public_dir)
    return nothing
end

"""Remove the cached and published files of the given dataset tags.

The directories that end up empty are removed as well; `public` itself is kept.
"""
function clean_database!(arttags::Vector{String})
    for arttag in arttags
        rm(_assert_managed_path(dataset_cache(arttag)); force = true)
        rm(_assert_managed_path(dataset_path(arttag)); force = true)
    end
    remove_empty_folders!(joinpath(GRIDDINGMACHINE_HOME, "public"))
    return nothing
end
