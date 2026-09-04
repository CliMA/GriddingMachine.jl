mktempdir() do root
    fixture = joinpath(root, "fixture.nc")
    data = reshape(Float32.(1:24), 4, 2, 3)
    raw_data = data .+ 100
    std_data = data .+ 200
    attributes = Dict{String,Any}("about" => "synthetic read_dataset fixture")
    save_nc!(fixture, "data", data, attributes)
    append_nc!(fixture, "raw_data", raw_data, attributes, ["lon", "lat", "ind"])
    append_nc!(fixture, "std", std_data, attributes, ["lon", "lat", "ind"])

    @test Indexer.read_dataset(fixture) == data
    @test Indexer.read_dataset(fixture; raw_data = true) == raw_data
    @test Indexer.read_dataset(fixture; read_std = true) == std_data
    @test Indexer.read_dataset(fixture, 2) == data[:, :, 2]
    @test Indexer.read_dataset(fixture, 2; raw_data = true) == raw_data[:, :, 2]
    @test Indexer.read_dataset(fixture, -45, -135) == vec(data[1, 1, :])
    @test Indexer.read_dataset(fixture, -45, -135, 3) == data[1, 1, 3]
    @test Indexer.read_dataset(fixture, 90, 180) == vec(data[4, 2, :])
    @test Indexer.read_LUT(fixture, -45, -135, 3) == Indexer.read_dataset(fixture, -45, -135, 3)

    extensionless = joinpath(root, "fixture-data")
    cp(fixture, extensionless)
    @test Indexer.read_dataset(extensionless) == data
    @test_throws ErrorException Indexer.read_dataset(joinpath(root, "missing.nc"))

    no_std = joinpath(root, "no-std.nc")
    save_nc!(no_std, "data", data[:, :, 1], attributes)
    @test isnothing(Indexer.read_dataset(no_std; read_std = true))

    @test Indexer.lat_ind(-90, 90) == 1
    @test Indexer.lat_ind(90, 90) == 2
    @test Indexer.lon_ind(-180, 90) == 1
    @test Indexer.lon_ind(180, 90) == 4
    @test Indexer.lon_ind(225, 90) == 1

    home = joinpath(root, "tag-home")
    catalog_file = joinpath(home, "Artifacts.yaml")
    tag = "SYNTHETIC_1X_1Y_V1"
    bytes = read(fixture)
    write_catalog(catalog_file, Dict(
        tag => catalog_entry(["https://fixture.invalid/data.nc"], bytes),
    ))
    Collector.configure!(; home, catalog_file, catalog_url = "https://catalog.invalid/catalog")
    Collector.load_database!(; download_if_missing = false)
    tagged_path = Collector.dataset_path(tag)
    mkpath(dirname(tagged_path))
    cp(fixture, tagged_path)
    @test Indexer.read_dataset(tag) == data
end
