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

    # A counter on a local catalog server lets the tests prove that answering a request never
    # re-downloads the catalog. Serve it under a path that `_catalog_download_url` accepts
    # verbatim, so nothing reaches an external host even if a refresh did happen.
    catalog_requests = Ref(0)
    catalog_port = free_port()
    catalog_body = read(joinpath(root, "gm-home", "Artifacts.yaml"), String)
    catalog_server = HTTP.serve!(Sockets.localhost, catalog_port; verbose = false) do request
        catalog_requests[] += 1
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
        # 遗留调试字段 "Nothing" 已移除
        @test !haskey(parsed, "Nothing")

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

        # An unknown tag yields a warning without re-downloading the catalog: a typo against a
        # catalog with over a thousand entries must not trigger a full refresh.
        before = catalog_requests[]
        unknown = payload("NOT_A_TAG_1X_1Y_V1", 10, 20, 0)
        @test haskey(unknown, "Warning")
        @test !haskey(unknown, "Data")
        @test unknown["Latitude"] == 10
        @test catalog_requests[] == before
        # the catalog stayed usable
        @test Collector.dataset_found(tag_2d)

        # include_std 默认为 true，行为与旧版一致
        @test payload(tag_3d, -45, -135, 0)["Stdv"] == Float64.(vec(data_3d[1, 1, :] .+ 1))

        # include_std=false 时 Stdv 置为 null 而不是删键：Requestor 会无条件读取该键
        without_std = JSON.parse(String(
            Server.sitedata_json(tag_3d, -45, -135, 0; include_std = false).body))
        @test haskey(without_std, "Stdv")
        @test isnothing(without_std["Stdv"])
        @test without_std["Data"] == Float64.(vec(data_3d[1, 1, :]))
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

            # `user` 是日志标签而不是凭据：任何取值都能拿到数据。
            # 旧实现用 `user in allowed_users` 做“鉴权”，但该值来自查询参数，
            # 任何调用方都能伪造，因此本版本不再假装它是权限控制。
            other_data, other_std = Requestor.request_site_data(
                "http://localhost:$port", "stranger", tag_2d, -45, -135,
            )
            @test other_data == Float64(data_2d[1, 1])
            @test other_std == Float64(data_2d[1, 1] + 1)

            # 查询页可访问，且含已登记的 tag
            page = HTTP.get("http://localhost:$port/"; retry = false, readtimeout = 10)
            @test page.status == 200
            @test occursin(tag_2d, String(page.body))

            # 新端点经真实 HTTP 可达；本夹具未登记陆面 tag，
            # 因此预期得到“数据不可用”载荷而不是异常
            gmdict = HTTP.get("http://localhost:$port/gmdict.json?gmversion=gm2&year=2020&lat=40&lon=-105";
                              retry = false, readtimeout = 10)
            @test gmdict.status == 200
            gmdict_body = JSON.parse(String(gmdict.body))
            @test gmdict_body["Warning"] == "Required datasets are not available"
            @test length(gmdict_body["MissingTags"]) == 14

            # 宽松布尔解析：include_std=1 不应使请求崩溃
            lenient = HTTP.get("http://localhost:$port/sitedata.json?tag=$tag_2d&lat=-45&lon=-135&cycle=0&include_std=1";
                               retry = false, readtimeout = 10)
            @test lenient.status == 200
            @test !isnothing(JSON.parse(String(lenient.body))["Stdv"])

            # 缺坐标时必须拒答，不得默认到另一个地点。
            # 可选开关（include_std/cycle）容错是对的，但坐标决定查的是哪里，
            # 静默替换会让调用方拿到不同地点的数据而不自知。
            for query in ("/sitedata.json?tag=$tag_2d&lat=&lon=",
                          "/sitedata.json?tag=$tag_2d&lon=-135",
                          "/sitedata.json?tag=$tag_2d&lat=north&lon=-135",
                          "/gmdict.json?gmversion=gm2&year=2020",
                          "/weather.json?wdversion=wd1&year=2020&lat=40")
                refused = HTTP.get("http://localhost:$port" * query; retry = false, readtimeout = 10)
                @test refused.status == 200
                refused_body = JSON.parse(String(refused.body))
                @test refused_body["Reason"] == Server.REASON_MISSING_COORDINATES
                @test !haskey(refused_body, "Data")
                @test !haskey(refused_body, "GridDict")
                @test !haskey(refused_body, "WeatherDrivers")
                @test haskey(refused_body, "Hint")
            end

            # 坐标齐备时 /weather.json 也要走到底：本夹具没登记气象 tag，
            # 因此预期是 MissingTags 而不是缺坐标
            weather = HTTP.get("http://localhost:$port/weather.json?wdversion=wd1&year=2020&lat=40&lon=-105";
                               retry = false, readtimeout = 10)
            @test weather.status == 200
            weather_body = JSON.parse(String(weather.body))
            @test weather_body["Warning"] == "Required datasets are not available"
            @test length(weather_body["MissingTags"]) == 8
            @test weather_body["Latitude"] == 40
        finally
            @test isnothing(Server.down_servers!())
        end
    end

    close(catalog_server)
end
