"""Update the catalog and synchronize selected tags (all tags by default)."""
function sync_database!(;
        tags = nothing,
        update::Bool = true,
        pause::Real = 0,
        update_kwargs = NamedTuple(),
        download_kwargs = NamedTuple(),
    )
    update ? update_database!(; update_kwargs...) : _ensure_database_loaded!()
    selected_tags = isnothing(tags) ? copy(YAML_TAGS) : String.(collect(tags))
    for arttag in selected_tags
        download_dataset!(arttag; download_kwargs...)
        pause > 0 && sleep(pause)
    end
    return nothing
end
