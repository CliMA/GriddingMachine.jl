#=
Server and Requestor.

`sitedata_json` is exercised against a staged catalog so it never downloads anything, and
the HTTP layer is exercised against a Genie server bound to a free local port. The
Requestor is additionally tested against a stub server that returns hand-written payloads,
so the -9999 <-> NaN translation can be checked independently of the Server code.
=#

mktempdir() do root
    tag_3d = "SITE_3D_1X_1M_V1"
    tag_2d = "SITE_2D_1X_1Y_V1"

    # 4 lon x 2 lat keeps the grid tiny while still giving distinct cells
    data_3d = reshape(Float32.(1:24), 4, 2, 3)
    data_2d = Float32[1 5; 2 6; 3 7; 4 8]
    # a cell that is missing on purpose, to check the NaN -> -9999 conversion
    data_nan = copy(data_2d)
    data_nan[1, 1] = NaN32
    tag_nan = "SITE_NAN_1X_1Y_V1"

    stage_datasets!(root, Dict(
        tag_3d => data_3d,
        tag_2d => data_2d,
        tag_nan => data_nan,
    ))

    # `sitedata_json` refreshes the catalog whenever it sees an unknown tag. Serve the
    # staged catalog from localhost under a path that `_catalog_download_url` accepts
    # verbatim, so that refresh path is exercised without any external request.
    catalog_port = free_port()
    catalog_body = read(joinpath(root, "gm-home", "Artifacts.yaml"), String)
    catalog_server = HTTP.serve!(Sockets.localhost, catalog_port; verbose = false) do request
        return HTTP.Response(200, catalog_body)
    end
    Collector.configure!(;
        home = joinpath(root, "gm-home"),
        catalog_file = joinpath(root, "gm-home", "Artifacts.yaml"),
        catalog_url = "http://localhost:$catalog_port/records/1/files/Artifacts.yaml",
    )
    Collector.load_database!(; download_if_missing = false)

    @testset "sitedata_json payloads" begin
        # Genie's json renderer returns an HTTP.Response, so unwrap the body before parsing
        payload(args...) = JSON.parse(String(Server.sitedata_json(args...).body))

        # cycle 0 on a 3D product returns the whole series for that cell
        parsed = payload(tag_3d, -45, -135, 0)
        @test parsed["Latitude"] == -45
        @test parsed["Longitude"] == -135
        @test parsed["Cycle"] == 0
        @test parsed["Data"] == Float64.(vec(data_3d[1, 1, :]))
        @test parsed["Stdv"] == Float64.(vec(data_3d[1, 1, :] .+ 1))
        @test isnothing(parsed["Nothing"])

        # a specific cycle returns a scalar
        single = payload(tag_3d, -45, -135, 3)
        @test single["Cycle"] == 3
        @test single["Data"] == Float64(data_3d[1, 1, 3])

        # cycle 0 on a 2D product also returns a scalar
        flat = payload(tag_2d, -45, -135, 0)
        @test flat["Data"] == Float64(data_2d[1, 1])

        # NaN is transmitted as -9999 because JSON has no NaN literal
        missing_scalar = payload(tag_nan, -45, -135, 0)
        @test missing_scalar["Data"] == -9999

        # an unknown tag triggers a catalog refresh and then yields a warning payload
        unknown = payload("NOT_A_TAG_1X_1Y_V1", 10, 20, 0)
        @test haskey(unknown, "Warning")
        @test !haskey(unknown, "Data")
        @test unknown["Latitude"] == 10
        # the refresh really ran and kept the catalog usable
        @test Collector.dataset_found(tag_2d)
    end

    @testset "Requestor against a stub server" begin
        port = free_port()
        # The stub answers /sitedata.json with whatever the query asks for, so each
        # translation branch of request_site_data can be driven independently.
        stub = HTTP.serve!(Sockets.localhost, port; verbose = false) do request
            target = HTTP.URIs.URI(request.target)
            query = Dict(HTTP.URIs.queryparams(target))
            kind = get(query, "tag", "scalar")
            payload = if kind == "scalar"
                Dict("Data" => 1.5, "Stdv" => 0.5)
            elseif kind == "scalar_missing"
                Dict("Data" => -9999, "Stdv" => -9999)
            elseif kind == "vector"
                Dict("Data" => [1.0, -9999, 3.0], "Stdv" => [0.1, -9999, 0.3])
            elseif kind == "null_stdv"
                Dict("Data" => 2.5, "Stdv" => nothing)
            else
                Dict("Warning" => "no data for you")
            end
            return HTTP.Response(200, JSON.json(payload))
        end
        server = "http://localhost:$port"

        try
            data, stdv = Requestor.request_site_data(server, "tester", "scalar", 30.5, 115.5)
            @test data == 1.5
            @test stdv == 0.5

            # -9999 becomes NaN again on the client side
            data, stdv = Requestor.request_site_data(server, "tester", "scalar_missing", 30.5, 115.5)
            @test isnan(data)
            @test isnan(stdv)

            data, stdv = Requestor.request_site_data(server, "tester", "vector", 30.5, 115.5)
            @test data[1] == 1.0
            @test isnan(data[2])
            @test data[3] == 3.0
            @test isnan(stdv[2])

            # a null Stdv must pass through untouched instead of being compared to -9999
            data, stdv = Requestor.request_site_data(server, "tester", "null_stdv", 30.5, 115.5)
            @test data == 2.5
            @test isnothing(stdv)

            # a payload without Data is a hard error
            @test_throws ErrorException Requestor.request_site_data(
                server, "tester", "warning", 30.5, 115.5,
            )
        finally
            close(stub)
        end
    end

    @testset "Server routes end to end" begin
        port = free_port()
        @test isnothing(Server.setup_url_input_routes!(["allowed"]))
        @test isnothing(Server.up_servers!(port))

        try
            # give the async server a moment to bind the port
            for _ in 1:50
                try
                    HTTP.get("http://localhost:$port/sitedata.json?user=allowed&tag=$tag_2d&lat=-45&lon=-135&cycle=0";
                             retry = false, readtimeout = 2)
                    break
                catch
                    sleep(0.2)
                end
            end

            data, stdv = Requestor.request_site_data(
                "http://localhost:$port", "allowed", tag_2d, -45, -135,
            )
            @test data == Float64(data_2d[1, 1])
            @test stdv == Float64(data_2d[1, 1] + 1)

            # an unlisted user is refused, and the Requestor reports the missing Data key
            @test_throws ErrorException Requestor.request_site_data(
                "http://localhost:$port", "stranger", tag_2d, -45, -135,
            )
        finally
            @test isnothing(Server.down_servers!())
        end
    end

    close(catalog_server)
end
