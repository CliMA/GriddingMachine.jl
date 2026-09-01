#= responses.jl: 缺失值编码、宽松参数解析、载荷构造、错误分类、所需 tag 枚举 =#

@testset "encode_missing" begin
    # NaN 无法出现在 JSON 里，统一编码为 -9999
    @test Server.encode_missing(1.5) == 1.5
    @test Server.encode_missing(NaN) == -9999
    @test Server.encode_missing([1.0, NaN, 3.0]) == [1.0, -9999, 3.0]
    # 编码不得原地修改入参
    original = [1.0, NaN]
    Server.encode_missing(original)
    @test isnan(original[2])
    # 整数与 nothing 原样透传
    @test Server.encode_missing(7) == 7
    @test isnothing(Server.encode_missing(nothing))
    @test Server.encode_missing("text") == "text"
end

@testset "宽松参数解析" begin
    # 可选项缺省、空白、无法解析时退回默认值而不是抛异常
    @test Server.parse_int("3", 0) == 3
    @test Server.parse_int("", 0) == 0
    @test Server.parse_int("3.7", 0) == 0

    # 旧实现用 parse(Bool, ...)，遇到 "1" 会抛异常
    @test Server.parse_bool("true", false)
    @test Server.parse_bool("1", false)
    @test Server.parse_bool("yes", false)
    @test Server.parse_bool("ON", false)
    @test !Server.parse_bool("false", true)
    @test !Server.parse_bool("0", true)
    @test !Server.parse_bool("no", true)
    # 无法识别时用默认值，不抛异常
    @test Server.parse_bool("", true)
    @test Server.parse_bool("maybe", true)
    @test !Server.parse_bool("maybe", false)
end

@testset "坐标不得默认填充" begin
    # 坐标决定查的是哪里，缺失时必须报 nothing；
    # 默认成另一个地点比拒答更糟。
    @test Server.parse_coordinate("40.03") == 40.03
    @test Server.parse_coordinate("-105.55") == -105.55
    @test Server.parse_coordinate(" 12 ") == 12.0
    @test Server.parse_coordinate("0") == 0.0
    @test isnothing(Server.parse_coordinate(""))
    @test isnothing(Server.parse_coordinate("   "))
    @test isnothing(Server.parse_coordinate("north"))
end

@testset "载荷构造" begin
    context = OrderedDict{String,Any}("User" => "tester", "Year" => 2020)

    warned = Server.warning_payload(Server.REASON_UNSUPPORTED, context)
    @test warned["Warning"] == "Your request cannot be completed"
    @test warned["Reason"] == "unsupported version"
    @test warned["User"] == "tester"
    @test warned["Year"] == 2020

    absent = Server.missing_datasets_payload(["A_1X_1Y_V1", "B_1X_1Y_V1"], context)
    @test absent["Warning"] == "Required datasets are not available"
    @test absent["MissingTags"] == ["A_1X_1Y_V1", "B_1X_1Y_V1"]
    @test haskey(absent, "Hint")
    @test absent["User"] == "tester"
end

@testset "错误分类" begin
    # grid_dict 通过 ErrorException 的消息文本表达入口条件
    @test Server.classify_error(ErrorException("The target grid does not contain land!")) ==
          Server.REASON_NO_LAND
    @test Server.classify_error(ErrorException("The target grid is not vegetated!")) ==
          Server.REASON_NOT_VEGETATED
    # 其余一律归为 internal error，且不把原始消息带出去
    @test Server.classify_error(ErrorException("/tmp/secret/path exploded")) ==
          Server.REASON_INTERNAL
    @test Server.classify_error(BoundsError()) == Server.REASON_INTERNAL
end

@testset "所需 tag 枚举" begin
    land = Indexer.LandDatasetLabels("gm2", 2020)
    land_tags = Server.required_tags(land)
    @test length(land_tags) == 14
    @test land.tag_t_lm in land_tags
    @test land.tag_p_lai in land_tags
    # 非 tag 字段不得混进来
    @test !("gm2" in land_tags)
    @test all(occursin("_", tag) for tag in land_tags)

    weather = Indexer.WeatherDriverLabels("wd1", 2020)
    weather_tags = Server.required_tags(weather)
    @test length(weather_tags) == 8
    @test weather.tag_t_air in weather_tags
end
