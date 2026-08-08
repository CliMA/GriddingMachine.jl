function _assert_managed_path(path::AbstractString)
    managed_root = abspath(GRIDDINGMACHINE_HOME)
    resolved = abspath(path)
    relative = relpath(resolved, managed_root)
    (relative == "." || isabspath(relative) || first(splitpath(relative)) == "..") &&
        error("Refusing to remove unmanaged path: $resolved")
    return resolved
end

"""Remove old or all downloaded datasets under the configured isolated data root."""
function clean_database!(selection::String = "old"; update::Bool = false)
    selection in ("old", "all") || throw(ArgumentError("selection must be 'old' or 'all'"))
    initialize_database!()
    public_dir = joinpath(GRIDDINGMACHINE_HOME, "public")

    if selection == "all"
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
    return nothing
end

function clean_database!(arttags::Vector{String})
    for arttag in arttags
        rm(_assert_managed_path(dataset_cache(arttag)); force = true)
        rm(_assert_managed_path(dataset_path(arttag)); force = true)
    end
    return nothing
end
