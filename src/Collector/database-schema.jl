struct CatalogValidationError <: Exception
    errors::Vector{String}
end

function Base.showerror(io::IO, error::CatalogValidationError)
    print(io, "Invalid GriddingMachine catalog:\n - ", join(error.errors, "\n - "))
end

function _normalized_urls(value)
    values = value isa AbstractString ? [value] : value isa AbstractVector ? value : Any[]
    return [String(url) for url in values if url isa AbstractString && !isempty(strip(url))]
end

function validate_catalog(database::AbstractDict)
    errors = String[]
    normalized = Dict{String,Any}()

    for (raw_tag, raw_entry) in database
        tag = String(raw_tag)
        occursin(r"^[A-Za-z0-9_.-]+$", tag) ||
            push!(errors, "dataset tag '$tag' contains unsupported characters")
        if !(raw_entry isa AbstractDict)
            push!(errors, "$tag must map to a catalog entry")
            continue
        end

        entry = Dict{String,Any}(String(key) => value for (key, value) in raw_entry)
        path = get(entry, "PATH", nothing)
        if !(path isa AbstractString) || isempty(strip(path)) || isabspath(path) || ".." in splitpath(path)
            push!(errors, "$tag.PATH must be a safe non-empty relative path")
        end

        urls = _normalized_urls(get(entry, "URL", nothing))
        isempty(urls) && push!(errors, "$tag.URL must contain at least one URL")
        for url in urls
            occursin(r"^(?:https?|ftp)://"i, url) ||
                push!(errors, "$tag.URL contains an unsupported URL scheme: $url")
        end

        size = get(entry, "SIZE", nothing)
        !isnothing(size) && (!(size isa Integer) || size isa Bool || size <= 0) &&
            push!(errors, "$tag.SIZE must be a positive byte count")

        sha256 = get(entry, "SHA256", get(entry, "SHA", nothing))
        if !isnothing(sha256) && (!(sha256 isa AbstractString) || !occursin(r"^[0-9a-fA-F]{64}$", sha256))
            push!(errors, "$tag.SHA256 must be a 64-character hexadecimal SHA-256 digest")
        end

        path_string = path isa AbstractString ? String(path) : ""
        normalized_entry = Dict{String,Any}("PATH" => path_string, "URL" => urls)
        isnothing(size) || (normalized_entry["SIZE"] = Int(size))
        isnothing(sha256) || (normalized_entry["SHA256"] = lowercase(String(sha256)))
        normalized[tag] = normalized_entry
    end

    isempty(errors) || throw(CatalogValidationError(errors))
    return normalized
end

function _ensure_database_loaded!()
    isempty(YAML_DATABASE) && load_database!()
    return nothing
end
