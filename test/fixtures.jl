#=
Shared fixtures for the GriddingMachine test suite.

Everything here stays inside a temporary directory: no test may touch the real
`~/GriddingMachine` tree, and no test may reach the network. Downloads are always
injected through the `downloader` / `probe` keywords of `Collector.download_dataset!`,
or avoided entirely by staging a file that already satisfies the catalog checks.
=#

sha256_hex(data::Vector{UInt8}) = bytes2hex(SHA.sha256(data))

function write_catalog(path, database)
    mkpath(dirname(path))
    write(path, YAML.write(database))
    return path
end

function catalog_entry(urls, data::Vector{UInt8}; path = "public/v0", integrity = true)
    entry = Dict{String,Any}("PATH" => path, "URL" => urls)
    if integrity
        entry["SIZE"] = length(data)
        entry["SHA256"] = sha256_hex(data)
    end
    return entry
end

"""Write a GriddingMachine-shaped NetCDF holding `data` (and optionally `std`)."""
function save_grid_nc!(path::String, data::Array; std::Union{Nothing,Array} = nothing)
    mkpath(dirname(path))
    attributes = Dict{String,Any}("about" => "synthetic test fixture", "unit" => "1")
    save_nc!(path, "data", data, attributes)
    if !isnothing(std)
        dims = ndims(data) == 2 ? ["lon", "lat"] : ["lon", "lat", "ind"]
        append_nc!(path, "std", std, attributes, dims)
    end
    return path
end

"""
    stage_datasets!(root, arrays)

Build one NetCDF per `tag => array` entry, register every tag in a fresh catalog with
correct `SIZE`/`SHA256`, point `Collector` at that catalog, and copy each file to the
location `Collector.dataset_path` expects. Afterwards `read_dataset(tag)` and
`download_dataset!(tag)` both resolve offline, because `download_dataset!` returns early
once `verify_dataset_file` passes.

Returns `(; home, catalog_file)` so a test can additionally serve the catalog over HTTP.
"""
function stage_datasets!(root::String, arrays::AbstractDict; catalog_url = "https://catalog.invalid/catalog")
    home = joinpath(root, "gm-home")
    staging = joinpath(root, "staging")
    catalog_file = joinpath(home, "Artifacts.yaml")

    database = Dict{String,Any}()
    files = Dict{String,String}()
    for (tag, array) in arrays
        source = save_grid_nc!(joinpath(staging, "$tag.nc"), array; std = array .+ 1)
        files[tag] = source
        database[tag] = catalog_entry(["https://fixture.invalid/$tag.nc"], read(source))
    end
    write_catalog(catalog_file, database)

    Collector.configure!(; home, catalog_file, catalog_url)
    Collector.load_database!(; download_if_missing = false)

    for (tag, source) in files
        destination = Collector.dataset_path(tag)
        mkpath(dirname(destination))
        cp(source, destination; force = true)
    end

    return (; home, catalog_file)
end

"""A land-mask style array where every cell is land except the one at `ocean`."""
function land_mask_array(nlon::Int, nlat::Int; ocean::Tuple{Int,Int} = (1, 1))
    mask = ones(Float32, nlon, nlat)
    mask[ocean...] = 0
    return mask
end

"""Reserve a TCP port by binding and immediately releasing it."""
function free_port()
    server = Sockets.listen(Sockets.localhost, 0)
    port = Sockets.getsockname(server)[2]
    close(server)
    return Int(port)
end
