"""Download a validated catalog and atomically make it the active in-memory state."""
function update_database!(;
        source::AbstractString = YAML_URL,
        catalog_file::AbstractString = YAML_FILE,
        downloader = Downloads.download,
        resolve_source::Bool = true,
    )
    download_database!(; source, catalog_file, downloader, resolve_source)
    load_database!(; catalog_file, download_if_missing = false)
    return nothing
end
