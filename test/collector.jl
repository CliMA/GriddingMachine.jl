#= Collector: catalog schema, transactional updates, mirror fallback, integrity, cleanup =#

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
        @test Collector._ping_latency(
            "Reply: time=12ms TTL=128\nReply: time<1ms TTL=128") == 6.25
        @test isinf(Collector._ping_latency("Request timed out."))

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

    @testset "Probe ordering and unreachable hosts" begin
        # A string that is not a URL cannot be probed and must sort as unreachable.
        @test isinf(Collector.probe_url("not-a-url"))
        # ICMP is not used off Windows, so every host scores Inf there.
        Sys.iswindows() || @test isinf(Collector.ip_address_ping("127.0.0.1"))

        urls = ["https://slow.invalid/x", "https://fast.invalid/x", "https://dead.invalid/x"]
        scores = Dict(urls[1] => 20.0, urls[2] => 5.0, urls[3] => Inf)
        @test Collector._ordered_urls(urls, url -> scores[url]) == [urls[2], urls[1], urls[3]]
        # Finite scores always precede Inf, and Inf candidates are still queued.
        @test length(Collector._ordered_urls(urls, _ -> Inf)) == 3
        # A probe that throws must degrade to Inf instead of aborting the download.
        @test Set(Collector._ordered_urls(urls, _ -> error("probe exploded"))) == Set(urls)
    end

    @testset "Legacy entries without integrity fields" begin
        legacy_path = Collector.dataset_path("LEGACY_1X_1Y_V1")
        mkpath(dirname(legacy_path))
        write(legacy_path, good_a)
        # Without SIZE/SHA256 the file is accepted in permissive mode ...
        @test Collector.verify_dataset_file(legacy_path, "LEGACY_1X_1Y_V1")
        # ... and rejected as soon as integrity is demanded.
        @test_throws Collector.CatalogValidationError Collector.verify_dataset_file(
            legacy_path, "LEGACY_1X_1Y_V1"; require_integrity = true,
        )
        @test !Collector.verify_dataset_file(joinpath(root, "absent.nc"), "LEGACY_1X_1Y_V1")
    end

    @testset "Unknown tags" begin
        @test !Collector.dataset_found("NO_SUCH_TAG_1X_1Y_V1")
        # refresh_missing = false keeps the failure local instead of hitting the network.
        @test_throws ErrorException Collector.download_dataset!(
            "NO_SUCH_TAG_1X_1Y_V1"; refresh_missing = false,
        )
    end

    @testset "Catalog download URL resolution" begin
        # A direct link to a YAML file is used verbatim, without contacting the host.
        direct = "https://zenodo.org/records/17732092/files/Artifacts.yaml"
        @test Collector._catalog_download_url(direct) == direct
        @test Collector._catalog_download_url(direct * "?download=1") == direct * "?download=1"
        @test Collector._catalog_download_url(
            "https://example.invalid/records/1/files/Artifacts.yml") ==
            "https://example.invalid/records/1/files/Artifacts.yml"

        # Anything else is treated as a landing page that has to be parsed. Serve the
        # three possible shapes from localhost instead of reaching Zenodo.
        port = free_port()
        absolute = "https://zenodo.org/records/424242/files/Artifacts.yaml"
        landing = HTTP.serve!(Sockets.localhost, port; verbose = false) do request
            if occursin("absolute", request.target)
                return HTTP.Response(200, "<a href=\"$absolute?download=1\">catalog</a>")
            elseif occursin("relative", request.target)
                return HTTP.Response(200, "<a href=\"/records/424242/files/Artifacts.yaml\">catalog</a>")
            elseif occursin("missing", request.target)
                return HTTP.Response(200, "<p>no catalog here</p>")
            end
            return HTTP.Response(404, "gone")
        end

        try
            base = "http://localhost:$port"
            @test Collector._catalog_download_url("$base/absolute") == "$absolute?download=1"
            # a root-relative link is completed against zenodo.org
            @test Collector._catalog_download_url("$base/relative") ==
                  "https://zenodo.org/records/424242/files/Artifacts.yaml"
            # a page without any catalog link, and a page that is simply gone
            @test_throws ErrorException Collector._catalog_download_url("$base/missing")
            @test_throws ErrorException Collector._catalog_download_url("$base/broken")
        finally
            close(landing)
        end
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
        @test Collector.dataset_dir("B_1X_1Y_V1") == dirname(Collector.dataset_path("B_1X_1Y_V1"))
        @test !isempty(Collector.local_datasets())
        # Compare normalised paths: catalog entries carry a forward-slash PATH, while
        # local_datasets walks the tree with readdir, so on Windows the two spellings of
        # the same file differ (public/v0 vs public\v0).
        expected = normpath(Collector.dataset_path("B_1X_1Y_V1"))
        # latest_datasets returns catalog-derived paths, not tags
        @test expected in normpath.(Collector.latest_datasets())
        @test expected in normpath.(Collector.local_datasets())

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

    @testset "移除空目录" begin
        nest = joinpath(root, "nest")
        # 自底向上：删掉最内层后父目录变空，也应被删除
        deep = joinpath(nest, "a", "b", "c")
        mkpath(deep)
        # 含文件的目录必须保留
        kept = joinpath(nest, "keep")
        mkpath(kept)
        write(joinpath(kept, "data.nc"), "payload")

        @test isnothing(Collector.remove_empty_folders!(nest))
        @test !isdir(deep)
        @test !isdir(joinpath(nest, "a"))
        @test isdir(kept)
        @test isfile(joinpath(kept, "data.nc"))
        # 目标目录自身保留，即使它现在只剩 keep
        @test isdir(nest)

        # 不存在的目录是无操作，而不是错误
        @test isnothing(Collector.remove_empty_folders!(joinpath(root, "absent-dir")))

        # 权限错误只是“此处无需清理”，不得中断整个遍历。
        # rm/readdir 抛的是 Base.IOError（uv 封装）而不是 SystemError。
        guarded = joinpath(root, "guarded")
        locked = joinpath(guarded, "locked")
        mkpath(locked)
        chmod(guarded, 0o500)   # 可读可进入但不可写 → rm 子目录应 EACCES
        try
            # 权限位在 Windows 与 root 下不生效，实证探测而不猜
            probe = joinpath(guarded, "probe")
            restricted = try
                touch(probe)
                rm(probe)
                false
            catch
                true
            end

            # 无论能不能写，都不得抛异常
            @test isnothing(Collector.remove_empty_folders!(guarded))
            # 真的受限时，子目录删不掉但进程仍正常返回
            restricted && @test isdir(locked)
        finally
            chmod(guarded, 0o700)
        end

        # 非预期的异常仍需被记录（而不是静默吞掉）
        @test isnothing(Collector._report_unless_benign(ErrorException("unexpected"), "somewhere"))
        # 良性的 IO 错误不记录
        @test isnothing(Collector._report_unless_benign(
            Base.IOError("denied", Base.UV_EACCES), "somewhere"))
    end
end
