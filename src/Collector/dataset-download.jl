function _sha256_file(path::AbstractString)
    return open(path, "r") do io
        bytes2hex(SHA.sha256(io))
    end
end

function verify_dataset_file(path::AbstractString, arttag::String; require_integrity::Bool = false)
    isfile(path) || return false
    expected_size, expected_sha256 = _expected_integrity(arttag)
    if require_integrity && (isnothing(expected_size) || isnothing(expected_sha256))
        throw(CatalogValidationError(["$arttag must define SIZE and SHA256 for verified download"]))
    end
    !isnothing(expected_size) && filesize(path) != expected_size && return false
    !isnothing(expected_sha256) && _sha256_file(path) != expected_sha256 && return false
    return true
end

function probe_url(url::AbstractString; timeout::Real = 5)
    startswith(lowercase(url), "http://") || startswith(lowercase(url), "https://") || return Inf
    started = time_ns()
    try
        response = HTTP.request(
            "HEAD",
            url;
            status_exception = false,
            connect_timeout = timeout,
            readtimeout = timeout,
        )
        response.status < 500 || return Inf
        return (time_ns() - started) / 1.0e9
    catch
        return Inf
    end
end

function _ordered_urls(urls::Vector{String}, probe)
    scores = [try
        probe(url)
    catch
        Inf
    end for url in urls]
    return urls[sortperm(eachindex(urls); by = index -> (isinf(scores[index]), scores[index], index))]
end

"""Download a NetCDF through mirror fallback and promote it only after integrity checks."""
function download_dataset!(
        arttag::String;
        downloader = Downloads.download,
        probe = probe_url,
        require_integrity::Bool = false,
        refresh_missing::Bool = true,
    )
    if !dataset_found(arttag)
        refresh_missing && update_database!()
        dataset_found(arttag) || error("Dataset $arttag does not exist in the catalog")
    end

    destination = dataset_path(arttag)
    if verify_dataset_file(destination, arttag; require_integrity)
        return destination
    end

    expected_size, expected_sha256 = _expected_integrity(arttag)
    if require_integrity && (isnothing(expected_size) || isnothing(expected_sha256))
        throw(CatalogValidationError(["$arttag must define SIZE and SHA256 for verified download"]))
    end

    initialize_database!()
    cache_dir = joinpath(GRIDDINGMACHINE_HOME, "cache")
    part_file = joinpath(cache_dir, ".$arttag.$(getpid()).part")
    rm(part_file; force = true)
    failures = String[]

    for url in _ordered_urls(dataset_url(arttag), probe)
        try
            downloader(url, part_file)
            isfile(part_file) || error("downloader did not create a file")
            if !isnothing(expected_size) && filesize(part_file) != expected_size
                error("size mismatch: expected $expected_size bytes, got $(filesize(part_file))")
            end
            if !isnothing(expected_sha256)
                actual_sha256 = _sha256_file(part_file)
                actual_sha256 == expected_sha256 || error("SHA-256 mismatch: expected $expected_sha256, got $actual_sha256")
            end

            mkpath(dirname(destination))
            mv(part_file, destination; force = true)
            return destination
        catch error_value
            push!(failures, "$url => $(sprint(showerror, error_value))")
            rm(part_file; force = true)
        end
    end

    rm(part_file; force = true)
    error("All mirrors failed for $arttag:\n - $(join(failures, "\n - "))")
end

# Kept as a compatibility shim. Protocol probing replaces platform-specific ICMP parsing.
ip_address_ping(::String) = Inf
