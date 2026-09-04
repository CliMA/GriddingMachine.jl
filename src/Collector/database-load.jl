"""Load and validate the local catalog, downloading it only when explicitly needed."""
function load_database!(;
        catalog_file::AbstractString = YAML_FILE,
        download_if_missing::Bool = true,
        source::AbstractString = YAML_URL,
        downloader = Downloads.download,
    )
    initialize_database!()
    if !isfile(catalog_file)
        download_if_missing || throw(ArgumentError("Catalog file does not exist: $catalog_file"))
        download_database!(; source, catalog_file, downloader)
    end

    raw_database = read_library(catalog_file)
    raw_database isa AbstractDict || throw(CatalogValidationError(["catalog root must be a mapping"]))
    database = validate_catalog(raw_database)

    empty!(YAML_DATABASE)
    merge!(YAML_DATABASE, database)
    empty!(YAML_TAGS)
    append!(YAML_TAGS, sort!(collect(keys(database))))
    return YAML_DATABASE, YAML_TAGS
end
