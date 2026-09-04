function _catalog_download_url(source::AbstractString)
    occursin(r"/files/.*\.ya?ml(?:\?|$)"i, source) && return String(source)

    response = HTTP.get(source; status_exception = false)
    200 <= response.status < 400 || error("Catalog landing page returned HTTP $(response.status): $source")
    html = String(response.body)
    matched = match(r"https?://[^\"']+/records/\d+/files/Artifacts\.ya?ml(?:\?download=1)?"i, html)
    if !isnothing(matched)
        # RegexMatch.match is a SubString, which Downloads.download cannot convert to Cstring
        return String(matched.match)
    end
    matched = match(r"/records/\d+/files/Artifacts\.ya?ml(?:\?download=1)?"i, html)
    isnothing(matched) && error("Could not locate Artifacts.yaml on catalog landing page: $source")
    return "https://zenodo.org$(matched.match)"
end

"""Download, validate, and transactionally replace the external YAML catalog."""
function download_database!(;
        source::AbstractString = YAML_URL,
        catalog_file::AbstractString = YAML_FILE,
        downloader = Downloads.download,
        resolve_source::Bool = true,
    )
    initialize_database!()
    catalog_dir = dirname(catalog_file)
    mkpath(catalog_dir)
    temporary_file = joinpath(catalog_dir, ".$((basename(catalog_file))).$(getpid()).tmp.yaml")
    backup_file = joinpath(catalog_dir, "Artifacts.previous.yaml")
    rm(temporary_file; force = true)

    try
        download_url = resolve_source ? _catalog_download_url(source) : String(source)
        downloader(download_url, temporary_file)
        raw_database = read_library(temporary_file)
        raw_database isa AbstractDict || throw(CatalogValidationError(["catalog root must be a mapping"]))
        validate_catalog(raw_database)

        had_catalog = isfile(catalog_file)
        had_catalog && cp(catalog_file, backup_file; force = true)
        try
            mv(temporary_file, catalog_file; force = true)
        catch
            had_catalog && isfile(backup_file) && cp(backup_file, catalog_file; force = true)
            rethrow()
        end
        return catalog_file
    catch
        rm(temporary_file; force = true)
        rethrow()
    end
end
