function _entry(arttag::AbstractString)
    _ensure_database_loaded!()
    haskey(YAML_DATABASE, arttag) || error("Dataset $arttag does not exist in the catalog")
    return YAML_DATABASE[String(arttag)]
end

"""Return the stable cache path kept for compatibility; downloads use unique `.part` files."""
function dataset_cache(arttag::String)
    _entry(arttag)
    return joinpath(GRIDDINGMACHINE_HOME, "cache", "$(arttag).nc")
end

function dataset_dir(arttag::String)
    entry = _entry(arttag)
    return joinpath(GRIDDINGMACHINE_HOME, entry["PATH"])
end

function dataset_found(arttag::String)
    _ensure_database_loaded!()
    return haskey(YAML_DATABASE, arttag)
end

function dataset_path(arttag::String)
    return joinpath(dataset_dir(arttag), "$(arttag).nc")
end

function dataset_url(arttag::String)
    return copy(_entry(arttag)["URL"])
end

"""Return a copy of the validated catalog metadata for one dataset tag."""
function dataset_info(arttag::String)
    return copy(_entry(arttag))
end

function _expected_integrity(arttag::String)
    entry = _entry(arttag)
    return get(entry, "SIZE", nothing), get(entry, "SHA256", nothing)
end
