using GriddingMachine
using GriddingMachine.Collector
using GriddingMachine.Indexer
using NetcdfIO: append_nc!, save_nc!
using SHA
using Test
using YAML

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

@testset verbose = true "GriddingMachine" begin
    mktempdir() do root
        home = joinpath(root, "gm-home")
        catalog_file = joinpath(home, "Artifacts.yaml")
        good_a = collect(codeunits("synthetic-netcdf-a"))
        good_b = collect(codeunits("synthetic-netcdf-b"))
        database = Dict(
            "A_1X_1Y_V1" => catalog_entry(["https://bad.invalid/A", "https://good.invalid/A"], good_a),
            "B_1X_1Y_V1" => catalog_entry(["https://good.invalid/B"], good_b),
            "LEGACY_1X_1Y_V1" => catalog_entry(["https://good.invalid/legacy"], good_a; integrity = false),
        )
        write_catalog(catalog_file, database)

        Collector.configure!(; home, catalog_file, catalog_url = "https://catalog.invalid/catalog")
        @test !isdir(joinpath(home, "cache"))

        @testset "Catalog initialization and schema" begin
            loaded, tags = Collector.load_database!(; download_if_missing = false)
            @test Set(tags) == Set(keys(database))
            @test loaded["A_1X_1Y_V1"]["SIZE"] == length(good_a)
            @test isdir(joinpath(home, "cache"))
            @test isdir(joinpath(home, "public"))
            @test_throws Collector.CatalogValidationError Collector.validate_catalog(
                Dict("BAD" => Dict("PATH" => "../outside", "URL" => String[])),
            )
        end

        @testset "Transactional catalog update" begin
            original_catalog = read(catalog_file)
            invalid_remote = write_catalog(
                joinpath(root, "invalid.yaml"),
                Dict("BAD" => Dict("PATH" => "../outside", "URL" => ["https://bad.invalid/data"])),
            )
            copier = (source, destination) -> cp(source, destination; force = true)
            @test_throws Collector.CatalogValidationError Collector.update_database!(;
                source = invalid_remote,
                downloader = copier,
                resolve_source = false,
            )
            @test read(catalog_file) == original_catalog
            @test Collector.dataset_found("A_1X_1Y_V1")

            updated = deepcopy(database)
            updated["C_1X_1Y_V1"] = catalog_entry(["https://good.invalid/C"], good_a)
            valid_remote = write_catalog(joinpath(root, "valid.yaml"), updated)
            @test isnothing(Collector.update_database!(;
                source = valid_remote,
                downloader = copier,
                resolve_source = false,
            ))
            @test Collector.dataset_found("C_1X_1Y_V1")
            @test isfile(joinpath(home, "Artifacts.previous.yaml"))
        end

        @testset "Mirror fallback, cache isolation, and integrity" begin
            attempts = String[]
            function fixture_downloader(url, destination)
                push!(attempts, url)
                if occursin("bad", url)
                    write(destination, "not-netcdf")
                elseif endswith(url, "/A") || endswith(url, "/C") || endswith(url, "/legacy")
                    write(destination, good_a)
                elseif endswith(url, "/B")
                    write(destination, good_b)
                else
                    error("unavailable fixture URL")
                end
                return destination
            end
            probe = url -> occursin("bad", url) ? 0.0 : 1.0

            stale_cache = Collector.dataset_cache("A_1X_1Y_V1")
            write(stale_cache, "stale-cache")
            downloaded = Collector.download_dataset!(
                "A_1X_1Y_V1";
                downloader = fixture_downloader,
                probe,
                require_integrity = true,
            )
            @test read(downloaded) == good_a
            @test attempts == ["https://bad.invalid/A", "https://good.invalid/A"]
            @test read(stale_cache, String) == "stale-cache"
            @test Collector.verify_dataset_file(downloaded, "A_1X_1Y_V1"; require_integrity = true)

            write(downloaded, "previous-formal-file")
            always_fail = (url, destination) -> error("forced failure")
            @test_throws ErrorException Collector.download_dataset!(
                "A_1X_1Y_V1";
                downloader = always_fail,
                probe = _ -> Inf,
                require_integrity = true,
            )
            @test read(downloaded, String) == "previous-formal-file"
            @test isempty(filter(name -> endswith(name, ".part"), readdir(joinpath(home, "cache"))))

            @test_throws Collector.CatalogValidationError Collector.download_dataset!(
                "LEGACY_1X_1Y_V1";
                downloader = fixture_downloader,
                probe,
                require_integrity = true,
            )
        end

        @testset "Sync, information, tree, and cleanup" begin
            fixture_downloader = function(url, destination)
                write(destination, endswith(url, "/B") ? good_b : good_a)
                return destination
            end
            @test isnothing(Collector.sync_database!(;
                tags = ["B_1X_1Y_V1", "C_1X_1Y_V1"],
                update = false,
                download_kwargs = (
                    downloader = fixture_downloader,
                    probe = _ -> 0.0,
                    require_integrity = true,
                ),
            ))
            @test Collector.dataset_info("B_1X_1Y_V1")["SHA256"] == sha256_hex(good_b)
            @test Collector.dataset_url("B_1X_1Y_V1") == ["https://good.invalid/B"]
            @test all(isfile, [Collector.dataset_path("B_1X_1Y_V1"), Collector.dataset_path("C_1X_1Y_V1")])

            orphan = joinpath(home, "public", "orphan.nc")
            write(orphan, "orphan")
            Collector.clean_database!("old"; update = false)
            @test !isfile(orphan)
            @test isfile(Collector.dataset_path("B_1X_1Y_V1"))

            Collector.clean_database!(["B_1X_1Y_V1"])
            @test !isfile(Collector.dataset_path("B_1X_1Y_V1"))
            Collector.clean_database!("all")
            @test isempty(Collector.local_datasets())
        end
    end

    @testset "Indexer read_dataset" begin
        include("indexer-read.jl")
    end

    @testset "Model input dictionaries" begin
        include("model-inputs.jl")
    end
end
