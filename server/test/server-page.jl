#=
查询页。

重点是 tag 选项必须在请求时生成：jianghao 的实现在 include 时读取 YAML_TAGS，
而那时它还是空数组，导致下拉框永远为空。
=#

mktempdir() do root
    tag_a = "PAGE_A_1X_1Y_V1"
    tag_b = "PAGE_B_1X_1Y_V1"
    stage_datasets!(root, Dict(
        tag_a => fill(Float32(1), 4, 2),
        tag_b => fill(Float32(2), 4, 2),
    ))

    html = Server.query_page()

    @testset "页面结构" begin
        @test occursin("<!DOCTYPE html>", html)
        # 三个页签容器
        @test occursin("id=\"panel-sitedata\"", html)
        @test occursin("id=\"panel-gmdict\"", html)
        @test occursin("id=\"panel-weather\"", html)
        # 结果面板与 datalist
        @test occursin("id=\"result\"", html)
        @test occursin("id=\"gm-tags\"", html)
        # 不引用任何外部资源
        @test !occursin("//cdn", lowercase(html))
        @test !occursin("https://", html)
    end

    @testset "tag 选项在请求时填充" begin
        # 这是空下拉框缺陷的回归测试
        @test occursin(tag_a, html)
        @test occursin(tag_b, html)
        # 占位符必须已被替换
        @test !occursin("{{TAG_OPTIONS}}", html)
    end

    @testset "只列出受支持的版本" begin
        # jianghao 的下拉框里有 gm3/gm4，但 LandDatasetLabels 只支持 gm1/gm2
        @test occursin("value=\"gm1\"", html)
        @test occursin("value=\"gm2\"", html)
        @test !occursin("value=\"gm3\"", html)
        @test !occursin("value=\"gm4\"", html)
        @test occursin("value=\"wd1\"", html)
    end

    @testset "经纬度标为必填" begin
        # 三个页签各一对 lat/lon，共 6 个必填框。
        # 页面用 JS 拦截点击而不是表单提交，所以靠 data-required 而不是浏览器原生校验。
        @test count("required data-required", html) == 6
        # 前端提示语存在，但服务端仍然自己校验（不能只靠客户端）
        @test occursin("Latitude and longitude are required", html)
    end

    @testset "目录为空时页面仍可渲染" begin
        empty_root = mktempdir()
        stage_datasets!(empty_root, Dict{String,Any}())
        empty_html = Server.query_page()
        @test occursin("<!DOCTYPE html>", empty_html)
        @test !occursin("{{TAG_OPTIONS}}", empty_html)
    end
end
