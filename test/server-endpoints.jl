#=
三个查询端点的载荷与失败分支。

全部依赖 stage_datasets! 预置的极小 NetCDF 夹具，因此不下载任何真实数据集，也不访问外网。
=#

mktempdir() do root
    nlon, nlat = 4, 2
    veg_lat, veg_lon = -45, -135     # 索引 (1, 1)
    bare_lat, bare_lon = -45, -45    # 索引 (2, 1)
    ocean_lat, ocean_lon = 45, 135   # 索引 (4, 2)

    constant2d(value) = fill(Float32(value), nlon, nlat)
    series3d(value, cycles) = fill(Float32(value), nlon, nlat, cycles)

    land = constant2d(1)
    land[4, 2] = 0

    lai = series3d(2.5, 12)
    lai[2, 1, :] .= 0

    pft = zeros(Float32, nlon, nlat, 17)
    pft[:, :, 3] .= 100

    labels = Indexer.LandDatasetLabels("gm2", 2020)
    weather_labels = Indexer.WeatherDriverLabels("wd1", 2020)

    land_arrays = Dict(
        labels.tag_t_lm  => land,
        labels.tag_p_lai => lai,
        labels.tag_s_cc  => constant2d(5),
        labels.tag_s_α   => series3d(300, 4),
        labels.tag_s_n   => series3d(1.6, 4),
        labels.tag_s_Θr  => series3d(0.08, 4),
        labels.tag_s_Θs  => series3d(0.45, 4),
        labels.tag_p_ch  => constant2d(15),
        labels.tag_p_chl => series3d(30, 12),
        labels.tag_p_ci  => series3d(0.8, 12),
        labels.tag_p_sla => constant2d(20),
        labels.tag_p_vcm => series3d(60, 12),
        labels.tag_t_ele => constant2d(1500),
        labels.tag_t_pft => pft,
    )
    weather_arrays = Dict(
        weather_labels.tag_patm    => series3d(101_325, 4),
        weather_labels.tag_ppt     => series3d(0, 4),
        weather_labels.tag_rad_dif => series3d(100, 4),
        weather_labels.tag_rad_dir => series3d(300, 4),
        weather_labels.tag_rad_lw  => series3d(350, 4),
        weather_labels.tag_t_air   => series3d(290, 4),
        weather_labels.tag_vpd     => series3d(1000, 4),
        weather_labels.tag_wind    => series3d(2, 4),
    )

    stage_datasets!(root, merge(land_arrays, weather_arrays))
    body(response) = String(response.body)
    payload(response) = JSON.parse(body(response))

    @testset "gmdict 成功载荷" begin
        parsed = payload(Server.gmdict_json("tester", "gm2", 2020, veg_lat, veg_lon))
        @test parsed["User"] == "tester"
        @test parsed["GMVersion"] == "gm2"
        @test parsed["Year"] == 2020
        @test parsed["Latitude"] == veg_lat
        @test parsed["Longitude"] == veg_lon
        dict = parsed["GridDict"]
        @test dict["ELEVATION"] ≈ 1500
        @test dict["SOIL_COLOR"] == 5
        @test length(dict["LAI"]) == 366
        @test !haskey(parsed, "Warning")
    end

    @testset "gmdict 失败分支" begin
        # 不受支持的版本：不构造 labels，直接给出稳定 Reason
        unsupported = payload(Server.gmdict_json("tester", "gm9", 2020, veg_lat, veg_lon))
        @test unsupported["Reason"] == Server.REASON_UNSUPPORTED
        @test !haskey(unsupported, "GridDict")

        # 海洋格点
        no_land = payload(Server.gmdict_json("tester", "gm2", 2020, ocean_lat, ocean_lon))
        @test no_land["Reason"] == Server.REASON_NO_LAND

        # 陆地但无植被
        bare = payload(Server.gmdict_json("tester", "gm2", 2020, bare_lat, bare_lon))
        @test bare["Reason"] == Server.REASON_NOT_VEGETATED

        # 失败响应不得泄露内部路径或堆栈
        for response_body in (body(Server.gmdict_json("tester", "gm2", 2020, ocean_lat, ocean_lon)),
                              body(Server.gmdict_json("tester", "gm9", 2020, veg_lat, veg_lon)))
            @test !occursin("Stacktrace", response_body)
            @test !occursin(root, response_body)
        end
    end

    @testset "gmdict 数据缺失" begin
        # 只登记部分所需 tag，缺失项应被一次性列出而不是抛异常
        partial_root = mktempdir()
        kept = Dict(labels.tag_t_lm => land, labels.tag_p_lai => lai)
        stage_datasets!(partial_root, kept)

        absent = payload(Server.gmdict_json("tester", "gm2", 2020, veg_lat, veg_lon))
        @test absent["Warning"] == "Required datasets are not available"
        @test Set(absent["MissingTags"]) ==
              Set(setdiff(Server.required_tags(labels), collect(keys(kept))))
        @test length(absent["MissingTags"]) == 12
        @test haskey(absent, "Hint")

        # 恢复完整夹具供后续测试使用
        stage_datasets!(root, merge(land_arrays, weather_arrays))
    end
end
