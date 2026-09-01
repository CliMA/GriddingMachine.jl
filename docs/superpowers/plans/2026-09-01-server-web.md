# Server 网页版实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `release/v0.5.0` 上为 GriddingMachine.jl 实现一个本地/内网可用的数据查询网页，提供单点读取、陆面参数字典、气象驱动三类查询，并修掉 `origin/jianghao` 实现中的 12 项已核实缺陷。

**Architecture:** 三个 JSON 端点 + 一个静态 HTML 页面。页面用原生 `fetch` 调用同一批 JSON 端点，因此不存在 POST 结果路由，界面与 API 共享同一条代码路径。共享的响应构造、参数解析、错误分类集中在 `responses.jl`，路由层只做「解析参数 → 调用 json 函数」。

**Tech Stack:** Julia 1.12.6、Genie（`route` / `params` / `up` / `down` / `Renderer.Json`）、OrderedCollections、Test。前端为原生 HTML/CSS/JS，无外部依赖、无 CDN。

**设计依据：** `docs/superpowers/specs/2026-09-01-server-web-design.md`

---

## 执行前置

- [ ] **确认工作分支与基线**

```bash
cd /Users/haomin/Desktop/code/Emerald/GriddingMachine.jl
git branch --show-current   # 期望：release/v0.5.0
git log --oneline -1        # 期望：231d7bb 添加Server网页版设计文档
git status --short          # 期望：空
```

全程在 `release/v0.5.0` 上工作，不新建分支。提交署名已配置为 `JhOo1 <122067603+jhOo1@users.noreply.github.com>`。

测试命令统一为：

```bash
export PATH="$HOME/.juliaup/bin:$PATH"
export JULIA_PKG_SERVER=https://mirrors.ustc.edu.cn/julia
julia --project=. -e 'using Pkg; Pkg.test()'
```

单独跑一个测试文件时用：

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A20 "<测试集名>"
```

---

## 文件结构

| 文件 | 职责 | 动作 |
|---|---|---|
| `src/Server/responses.jl` | 缺失值编码、宽松参数解析、载荷构造、错误分类、所需 tag 枚举 | 新建 |
| `src/Server/json-site-data.jl` | 单点读取端点 | 修改（加 `include_std`、删 `Nothing` 字段） |
| `src/Server/json-grid-dict.jl` | 陆面参数字典端点 | 新建 |
| `src/Server/json-grid-weather.jl` | 气象驱动端点 | 新建 |
| `src/Server/web-page.jl` | 查询页 HTML 模板与 tag 选项注入 | 新建 |
| `src/Server/route-setup.jl` | 路由注册（改薄） | 重写 |
| `src/Server/Server.jl` | 模块导入与 include | 修改 |
| `src/Collector/database-remove-folder.jl` | `remove_empty_folders!` | 新建（自 jianghao 移植） |
| `src/Collector/Collector.jl` | include 与导出 | 修改 |
| `test/server-responses.jl` | `responses.jl` 单元测试 | 新建 |
| `test/server-endpoints.jl` | 三个端点的载荷与失败分支测试 | 新建 |
| `test/server-page.jl` | 查询页测试 | 新建 |
| `test/server-requestor.jl` | 现有；更新受影响断言 | 修改 |
| `test/collector.jl` | 现有；追加 `remove_empty_folders!` 测试 | 修改 |
| `test/runtests.jl` | 编排 | 修改 |
| `README.md`、`docs/src/API.md` | 文档 | 修改 |

`route-setup.jl` 预计由 27 行（当前）扩到约 60 行，覆盖 4 个路由；对比 jianghao 的 181 行覆盖 12 个路由。

---

## Task 1: responses.jl 共享层

**Files:**
- Create: `src/Server/responses.jl`
- Create: `test/server-responses.jl`
- Modify: `src/Server/Server.jl`
- Modify: `test/runtests.jl`

- [ ] **Step 1: 写失败测试**

创建 `test/server-responses.jl`：

```julia
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
    @test Server.parse_float("35.5", 0.0) == 35.5
    @test Server.parse_float("-135", 0.0) == -135.0
    # 缺省、空白、无法解析时退回默认值而不是抛异常
    @test Server.parse_float("", 30.5) == 30.5
    @test Server.parse_float("  ", 30.5) == 30.5
    @test Server.parse_float("not-a-number", 30.5) == 30.5

    @test Server.parse_int("3", 0) == 3
    @test Server.parse_int("", 0) == 0
    @test Server.parse_int("3.7", 0) == 0

    # jianghao 用 parse(Bool, ...)，遇到 "1" 会抛异常
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
```

在 `test/runtests.jl` 的 `@testset verbose = true "Server and Requestor"` 之前插入：

```julia
    @testset verbose = true "Server responses" begin
        include("server-responses.jl")
    end
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | tail -20
```

预期：`UndefVarError: encode_missing not defined`（或 `Server.encode_missing` 不存在）。

- [ ] **Step 3: 实现 responses.jl**

创建 `src/Server/responses.jl`：

```julia
#=
Shared helpers for the Server endpoints.

Note on the `user` parameter used throughout this module: it is a free-form label that is
echoed into responses and written to the log. It is NOT an access control mechanism — any
caller may supply any value. This server is meant for a local or trusted intranet network.
=#

"""Stable, machine-readable reasons returned to clients."""
const REASON_UNSUPPORTED = "unsupported version"
const REASON_NO_LAND = "no land at target grid"
const REASON_NOT_VEGETATED = "grid is not vegetated"
const REASON_INTERNAL = "internal error"

"""Value used in place of `NaN`, which JSON cannot represent."""
const MISSING_CODE = -9999

"""Encode `NaN` as `MISSING_CODE`; other values pass through unchanged."""
function encode_missing end

encode_missing(value) = value
encode_missing(value::Number) = isnan(value) ? MISSING_CODE : value
encode_missing(value::AbstractArray) = replace(value, NaN => MISSING_CODE)

"""Parse `raw` as `Float64`, falling back to `default` when empty or malformed."""
function parse_float(raw, default::Real)
    text = strip(String(raw))
    isempty(text) && return Float64(default)
    parsed = tryparse(Float64, text)
    return isnothing(parsed) ? Float64(default) : parsed
end

"""Parse `raw` as `Int`, falling back to `default` when empty or malformed."""
function parse_int(raw, default::Int)
    text = strip(String(raw))
    isempty(text) && return default
    parsed = tryparse(Int, text)
    return isnothing(parsed) ? default : parsed
end

const TRUTHY_TEXT = ("true", "1", "yes", "on")
const FALSY_TEXT = ("false", "0", "no", "off")

"""Parse `raw` as a flag, falling back to `default` when empty or unrecognised.

Deliberately lenient: `parse(Bool, "1")` throws, which made the equivalent query parameter
in the previous implementation crash the request.
"""
function parse_bool(raw, default::Bool)
    text = lowercase(strip(String(raw)))
    isempty(text) && return default
    text in TRUTHY_TEXT && return true
    text in FALSY_TEXT && return false
    return default
end

function _payload(head::AbstractDict, fields::AbstractDict)
    payload = OrderedDict{String,Any}(head)
    for (key, value) in fields
        payload[String(key)] = value
    end
    return payload
end

"""Build a failure payload carrying a stable `Reason` and the request context."""
function warning_payload(reason::AbstractString, fields::AbstractDict)
    head = OrderedDict{String,Any}(
        "Warning" => "Your request cannot be completed",
        "Reason" => String(reason),
    )
    return _payload(head, fields)
end

"""Build a payload naming every catalog tag the request needs but cannot find."""
function missing_datasets_payload(absent::Vector{String}, fields::AbstractDict)
    head = OrderedDict{String,Any}(
        "Warning" => "Required datasets are not available",
        "MissingTags" => absent,
        "Hint" => "These tags are not registered in the local catalog",
    )
    return _payload(head, fields)
end

"""Map an exception to a stable reason, keeping its message out of the response.

`grid_dict` signals its entry conditions through `ErrorException` messages, so this matches
on the message text. That is a deliberate trade-off: re-implementing the land-mask and LAI
checks here would create a second copy of logic that lives in `Indexer`. The tests pin both
mappings, so an upstream wording change fails the suite instead of silently degrading to
`internal error`.
"""
function classify_error(exception)
    message = sprint(showerror, exception)
    occursin("does not contain land", message) && return REASON_NO_LAND
    occursin("not vegetated", message) && return REASON_NOT_VEGETATED
    return REASON_INTERNAL
end

"""Return every catalog tag a labels struct depends on, read from its `tag_*` fields."""
function required_tags(labels)
    names = fieldnames(typeof(labels))
    return String[getfield(labels, name) for name in names if startswith(String(name), "tag_")]
end

"""Return the subset of `tags` that is absent from the local catalog."""
function missing_tags(tags::Vector{String})
    return String[tag for tag in tags if !dataset_found(tag)]
end
```

修改 `src/Server/Server.jl`。**本步只加 `responses.jl` 一个 include**；`json-grid-dict.jl`、`json-grid-weather.jl`、`web-page.jl` 将在 Task 3、4、5 各自创建时再加入，提前加会导致模块加载失败。把整个文件替换为：

```julia
module Server

import Genie.Renderer.Json as GRJSON

using Genie: down, params, route, up
using OrderedCollections: OrderedDict

using ..Collector: YAML_TAGS, dataset_found, download_dataset!, update_database!
using ..Indexer: LandDatasetLabels, WeatherDriverLabels, grid_dict, grid_weather, read_dataset


include("responses.jl");
include("json-site-data.jl");
include("route-setup.jl");
include("route-up-down.jl");


end; # module
```

相对原文件的变化：新增 `using OrderedCollections: OrderedDict`；导入清单增加 `dataset_found`（供 `missing_tags` 使用）与 `LandDatasetLabels, WeatherDriverLabels, grid_dict, grid_weather`（供 Task 3/4 使用）；新增 `include("responses.jl")`；删除原文件尾部的大段注释掉的旧 include 列表。

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A8 "Server responses"
```

预期：`Server responses` 测试集全绿；`GriddingMachine` 总数由 193 增至约 230。

- [ ] **Step 5: 提交**

```bash
git add src/Server/responses.jl src/Server/Server.jl test/server-responses.jl test/runtests.jl
git commit -m "添加Server共享响应层"
```

---

## Task 2: json-site-data.jl 扩展 include_std 并移除 Nothing 字段

**Files:**
- Modify: `src/Server/json-site-data.jl`
- Modify: `test/server-requestor.jl`

- [ ] **Step 1: 写失败测试**

在 `test/server-requestor.jl` 的 `@testset "sitedata_json payloads"` 内，把现有这一行删除：

```julia
        @test isnothing(parsed["Nothing"])
```

替换为：

```julia
        # 遗留调试字段 "Nothing" 已移除
        @test !haskey(parsed, "Nothing")
```

并在该 testset 末尾（`@test Collector.dataset_found(tag_2d)` 之后）追加：

```julia
        # include_std 默认为 true，行为与旧版一致
        @test payload(tag_3d, -45, -135, 0)["Stdv"] == Float64.(vec(data_3d[1, 1, :] .+ 1))

        # include_std=false 时 Stdv 置为 null 而不是删键：Requestor 会无条件读取该键
        without_std = JSON.parse(String(
            Server.sitedata_json(tag_3d, -45, -135, 0; include_std = false).body))
        @test haskey(without_std, "Stdv")
        @test isnothing(without_std["Stdv"])
        @test without_std["Data"] == Float64.(vec(data_3d[1, 1, :]))
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -B2 -A6 "sitedata_json payloads"
```

预期：`!haskey(parsed, "Nothing")` 失败（字段仍存在），以及 `MethodError` —— `sitedata_json` 尚不接受 `include_std` 关键字。

- [ ] **Step 3: 实现**

把 `src/Server/json-site-data.jl` 整个文件替换为：

```julia
"""

    sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)

Return an HTTP response whose body is the JSON-encoded dataset value at one grid cell, given
- `arttag` the dataset tag (e.g., "CH_2X_1Y_V2")
- `lat` the target latitude
- `lon` the target longitude
- `cyc` the cycle number (0 reads every cycle)
- `include_std` whether to report the error variable (default `true`)

Missing values are encoded as -9999 because JSON has no NaN literal;
`Requestor.request_site_data` converts them back to NaN.

When `include_std` is `false` the `Stdv` key is set to `null` rather than removed, because
`Requestor.request_site_data` reads that key unconditionally.
"""
function sitedata_json(arttag::String, lat::Number, lon::Number, cyc::Int; include_std::Bool = true)
    # refresh the catalog once if the tag is unknown, in case it was published upstream
    if !(arttag in YAML_TAGS)
        update_database!();
    end;

    if arttag in YAML_TAGS
        fpath = download_dataset!(arttag);
        if isfile(fpath)
            if cyc == 0
                data = read_dataset(fpath, lat, lon);
                stdv = include_std ? read_dataset(fpath, lat, lon; read_std = true) : nothing;
            else
                data = read_dataset(fpath, lat, lon, cyc);
                stdv = include_std ? read_dataset(fpath, lat, lon, cyc; read_std = true) : nothing;
            end;

            json_dict = OrderedDict{String,Any}(
                "Latitude"  => lat,
                "Longitude" => lon,
                "Cycle"     => cyc,
                "Data"      => encode_missing(data),
                "Stdv"      => encode_missing(stdv),
            );

            return GRJSON.json(json_dict)
        end;
    end;

    json_warn = OrderedDict{String,Any}(
        "Warning"   => "Your request cannot be completed, please check your settings",
        "Latitude"  => lat,
        "Longitude" => lon,
        "Cycle"     => cyc,
    );

    return GRJSON.json(json_warn)
end;
```

三处变化：新增 `include_std` 关键字；`NaN` 编码改用共享的 `encode_missing`（原先是内联的 `replace` 与 `isnan` 分支）；移除 `"Nothing" => nothing` 字段。响应键顺序与类型不变。

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A6 "Server and Requestor"
```

预期：`sitedata_json payloads` 全绿；`Requestor against a stub server` 与 `Server routes end to end` 保持全绿（契约未破）。

- [ ] **Step 5: 提交**

```bash
git add src/Server/json-site-data.jl test/server-requestor.jl
git commit -m "sitedata端点支持include_std并移除遗留字段"
```

---

## Task 3: json-grid-dict.jl 陆面参数字典端点

**Files:**
- Create: `src/Server/json-grid-dict.jl`
- Create: `test/server-endpoints.jl`
- Modify: `src/Server/Server.jl`
- Modify: `test/runtests.jl`

- [ ] **Step 1: 写失败测试**

创建 `test/server-endpoints.jl`。夹具与 `test/grid-from-tags.jl` 同构：4×2 网格，(1,1) 为植被格点、(2,1) 为裸土、(4,2) 为海洋。

```julia
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

    staged = stage_datasets!(root, merge(land_arrays, weather_arrays))
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
```

在 `test/runtests.jl` 中，紧随 `"Server responses"` 之后插入：

```julia
    @testset verbose = true "Server endpoints" begin
        include("server-endpoints.jl")
    end
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | tail -20
```

预期：`UndefVarError: gmdict_json not defined`。

- [ ] **Step 3: 实现**

创建 `src/Server/json-grid-dict.jl`：

```julia
"""Land parameter collections this endpoint accepts."""
const SUPPORTED_GM_VERSIONS = ("gm1", "gm2")

"""

    gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)

Return an HTTP response whose body is the JSON-encoded land parameter dictionary for one
grid cell, given
- `user` free-form label echoed back and logged; not an access control mechanism
- `gmversion` land parameter collection, one of `SUPPORTED_GM_VERSIONS`
- `year` year selecting the time dependent products
- `lat` the target latitude
- `lon` the target longitude

Missing values are encoded as -9999. When a required dataset is absent from the local
catalog the response lists the missing tags instead of raising, and no remote catalog
refresh is triggered: downloading is the responsibility of `Collector`.
"""
function gmdict_json(user::String, gmversion::String, year::Int, lat::Number, lon::Number)
    context = OrderedDict{String,Any}(
        "User" => user,
        "GMVersion" => gmversion,
        "Year" => year,
        "Latitude" => lat,
        "Longitude" => lon,
    )

    gmversion in SUPPORTED_GM_VERSIONS ||
        return GRJSON.json(warning_payload(REASON_UNSUPPORTED, context))

    labels = LandDatasetLabels(gmversion, year)
    absent = missing_tags(required_tags(labels))
    isempty(absent) || return GRJSON.json(missing_datasets_payload(absent, context))

    gm_dict = try
        grid_dict(labels, lat, lon)
    catch exception
        @error "gmdict request failed" user gmversion year lat lon exception
        return GRJSON.json(warning_payload(classify_error(exception), context))
    end

    payload = OrderedDict{String,Any}(context)
    payload["GridDict"] = OrderedDict{String,Any}(
        String(key) => encode_missing(value) for (key, value) in gm_dict
    )

    return GRJSON.json(payload)
end;
```

在 `src/Server/Server.jl` 的 include 段，于 `json-site-data.jl` 之后加入一行：

```julia
include("json-grid-dict.jl");
```

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A8 "Server endpoints"
```

预期：`gmdict 成功载荷`、`gmdict 失败分支`、`gmdict 数据缺失` 三个测试集全绿。

- [ ] **Step 5: 提交**

```bash
git add src/Server/json-grid-dict.jl src/Server/Server.jl test/server-endpoints.jl test/runtests.jl
git commit -m "添加陆面参数字典查询端点"
```

---

## Task 4: json-grid-weather.jl 气象驱动端点

**Files:**
- Create: `src/Server/json-grid-weather.jl`
- Modify: `src/Server/Server.jl`
- Modify: `test/server-endpoints.jl`

- [ ] **Step 1: 写失败测试**

在 `test/server-endpoints.jl` 的 `@testset "gmdict 数据缺失"` 之后、`mktempdir` 闭合之前追加：

```julia
    @testset "weather 成功载荷" begin
        parsed = payload(Server.weather_json("tester", "wd1", 2020, veg_lat, veg_lon))
        @test parsed["User"] == "tester"
        @test parsed["WDVersion"] == "wd1"
        @test parsed["Year"] == 2020
        drivers = parsed["WeatherDrivers"]
        @test Set(keys(drivers)) == Set([
            "FDOY", "PATM", "PPT", "RAD_SW_DIF", "RAD_SW_DIR", "RAD_LW", "TAIR", "VPD", "WIND",
        ])
        @test all(value ≈ 101_325 for value in drivers["PATM"])
        @test length(drivers["FDOY"]) == 4
        @test !haskey(parsed, "Warning")
    end

    @testset "weather 失败分支" begin
        unsupported = payload(Server.weather_json("tester", "wd9", 2020, veg_lat, veg_lon))
        @test unsupported["Reason"] == Server.REASON_UNSUPPORTED
        @test !haskey(unsupported, "WeatherDrivers")
    end

    @testset "weather 数据缺失" begin
        # 论文记录：2020 年 wd1 的 8 个 ERA5 条目只登记机构 FTP、校外不可达。
        # 这里模拟同样的状态：目录里只有陆面 tag，没有任何气象 tag。
        weather_absent_root = mktempdir()
        stage_datasets!(weather_absent_root, land_arrays)

        absent = payload(Server.weather_json("tester", "wd1", 2020, veg_lat, veg_lon))
        @test absent["Warning"] == "Required datasets are not available"
        @test Set(absent["MissingTags"]) == Set(Server.required_tags(weather_labels))
        @test length(absent["MissingTags"]) == 8
        @test !occursin("Stacktrace", body(Server.weather_json("tester", "wd1", 2020, veg_lat, veg_lon)))

        stage_datasets!(root, merge(land_arrays, weather_arrays))
    end
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | tail -20
```

预期：`UndefVarError: weather_json not defined`。

- [ ] **Step 3: 实现**

创建 `src/Server/json-grid-weather.jl`：

```julia
"""Weather driver collections this endpoint accepts."""
const SUPPORTED_WD_VERSIONS = ("wd1",)

"""

    weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)

Return an HTTP response whose body is the JSON-encoded weather driver series for one grid
cell, given
- `user` free-form label echoed back and logged; not an access control mechanism
- `wdversion` weather driver collection, one of `SUPPORTED_WD_VERSIONS`
- `year` year of the weather series
- `lat` the target latitude
- `lon` the target longitude

Missing values are encoded as -9999. The weather products are large and are commonly
absent from a local catalog, so an incomplete catalog produces a response that names every
missing tag rather than an exception.
"""
function weather_json(user::String, wdversion::String, year::Int, lat::Number, lon::Number)
    context = OrderedDict{String,Any}(
        "User" => user,
        "WDVersion" => wdversion,
        "Year" => year,
        "Latitude" => lat,
        "Longitude" => lon,
    )

    wdversion in SUPPORTED_WD_VERSIONS ||
        return GRJSON.json(warning_payload(REASON_UNSUPPORTED, context))

    labels = WeatherDriverLabels(wdversion, year)
    absent = missing_tags(required_tags(labels))
    isempty(absent) || return GRJSON.json(missing_datasets_payload(absent, context))

    wd_dict = try
        grid_weather(labels, lat, lon)
    catch exception
        @error "weather request failed" user wdversion year lat lon exception
        return GRJSON.json(warning_payload(classify_error(exception), context))
    end

    payload = OrderedDict{String,Any}(context)
    payload["WeatherDrivers"] = OrderedDict{String,Any}(
        String(key) => encode_missing(value) for (key, value) in wd_dict
    )

    return GRJSON.json(payload)
end;
```

在 `src/Server/Server.jl` 的 include 段，于 `json-grid-dict.jl` 之后加入：

```julia
include("json-grid-weather.jl");
```

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A14 "Server endpoints"
```

预期：weather 三个测试集全绿。

- [ ] **Step 5: 提交**

```bash
git add src/Server/json-grid-weather.jl src/Server/Server.jl test/server-endpoints.jl
git commit -m "添加气象驱动查询端点"
```


---

## Task 5: web-page.jl 查询页

**Files:**
- Create: `src/Server/web-page.jl`
- Create: `test/server-page.jl`
- Modify: `src/Server/Server.jl`
- Modify: `test/runtests.jl`

- [ ] **Step 1: 写失败测试**

创建 `test/server-page.jl`：

```julia
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
        @test !occursin("http://", replace(html, "http://localhost" => ""))
        @test !occursin("cdn", lowercase(html))
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

    @testset "目录为空时页面仍可渲染" begin
        empty_root = mktempdir()
        stage_datasets!(empty_root, Dict{String,Any}())
        empty_html = Server.query_page()
        @test occursin("<!DOCTYPE html>", empty_html)
        @test !occursin("{{TAG_OPTIONS}}", empty_html)
    end
end
```

在 `test/runtests.jl` 中，紧随 `"Server endpoints"` 之后插入：

```julia
    @testset verbose = true "Server page" begin
        include("server-page.jl")
    end
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | tail -20
```

预期：`UndefVarError: query_page not defined`。

- [ ] **Step 3: 实现**

创建 `src/Server/web-page.jl`：

```julia
#=
The query page.

The tag list is injected on every request, not at include time: `YAML_TAGS` is empty until
`Collector.load_database!` runs, so a template built at load time would always ship an empty
selector.
=#

"""Placeholder replaced with `<option>` elements for every catalog tag."""
const TAG_OPTIONS_PLACEHOLDER = "{{TAG_OPTIONS}}"

const PAGE_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>GriddingMachine query</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 0; padding: 1.5rem; background: #f6f7f9; color: #1c1e21; }
  h1 { font-size: 1.25rem; margin: 0 0 1rem; }
  .note { background: #fff6e5; border-left: 3px solid #e8a33d; padding: .6rem .8rem; font-size: .85rem; margin-bottom: 1rem; }
  .tabs { display: flex; gap: .4rem; margin-bottom: -1px; }
  .tabs button { border: 1px solid #ccd0d5; border-bottom: none; background: #e9ebee; padding: .5rem .9rem; cursor: pointer; font-size: .9rem; }
  .tabs button.active { background: #fff; font-weight: 600; }
  .panel { display: none; background: #fff; border: 1px solid #ccd0d5; padding: 1rem; }
  .panel.active { display: block; }
  .field { display: flex; align-items: center; gap: .5rem; margin-bottom: .6rem; }
  .field label { width: 11rem; font-size: .85rem; }
  .field input, .field select { padding: .3rem .4rem; font-size: .9rem; min-width: 15rem; }
  button.run { margin-top: .4rem; padding: .45rem 1.1rem; font-size: .9rem; cursor: pointer; }
  #status { margin: 1rem 0 .4rem; font-size: .9rem; }
  #status.error { color: #b3261e; }
  pre { background: #1c1e21; color: #e6e6e6; padding: .8rem; overflow: auto; max-height: 26rem; font-size: .8rem; }
  .toggle { font-size: .85rem; margin-bottom: .4rem; display: block; }
</style>
</head>
<body>
<h1>GriddingMachine query</h1>

<div class="note">
  This page is meant for a local or trusted intranet network. There is no access control:
  the <code>user</code> field is a label written to the server log, not a credential.
  The land parameter query downloads whole datasets on first use and can take several minutes.
</div>

<div class="tabs">
  <button data-panel="panel-sitedata" class="active">Site data</button>
  <button data-panel="panel-gmdict">Land parameters</button>
  <button data-panel="panel-weather">Weather drivers</button>
</div>

<div id="panel-sitedata" class="panel active" data-endpoint="/sitedata.json">
  <div class="field"><label for="sd-tag">Dataset tag</label>
    <input id="sd-tag" name="tag" list="gm-tags" placeholder="type to filter, e.g. ELEV"></div>
  <div class="field"><label for="sd-lat">Latitude</label>
    <input id="sd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="sd-lon">Longitude</label>
    <input id="sd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="sd-cycle">Cycle (0 = all)</label>
    <input id="sd-cycle" name="cycle" type="number" step="1" value="0"></div>
  <div class="field"><label for="sd-std">Include error variable</label>
    <input id="sd-std" name="include_std" type="checkbox" checked></div>
  <div class="field"><label for="sd-user">User label</label>
    <input id="sd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<div id="panel-gmdict" class="panel" data-endpoint="/gmdict.json">
  <div class="field"><label for="gd-version">Collection</label>
    <select id="gd-version" name="gmversion">
      <option value="gm1">gm1</option>
      <option value="gm2" selected>gm2</option>
    </select></div>
  <div class="field"><label for="gd-year">Year</label>
    <input id="gd-year" name="year" type="number" step="1" value="2020"></div>
  <div class="field"><label for="gd-lat">Latitude</label>
    <input id="gd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="gd-lon">Longitude</label>
    <input id="gd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="gd-user">User label</label>
    <input id="gd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<div id="panel-weather" class="panel" data-endpoint="/weather.json">
  <div class="field"><label for="wd-version">Collection</label>
    <select id="wd-version" name="wdversion">
      <option value="wd1" selected>wd1</option>
    </select></div>
  <div class="field"><label for="wd-year">Year</label>
    <input id="wd-year" name="year" type="number" step="1" value="2020"></div>
  <div class="field"><label for="wd-lat">Latitude</label>
    <input id="wd-lat" name="lat" type="number" step="any" value="40.03"></div>
  <div class="field"><label for="wd-lon">Longitude</label>
    <input id="wd-lon" name="lon" type="number" step="any" value="-105.55"></div>
  <div class="field"><label for="wd-user">User label</label>
    <input id="wd-user" name="user" value="anonymous"></div>
  <button class="run">Query</button>
</div>

<datalist id="gm-tags">
$(TAG_OPTIONS_PLACEHOLDER)
</datalist>

<div id="status"></div>
<label class="toggle"><input id="expand" type="checkbox"> Expand full arrays</label>
<pre id="result">No query yet.</pre>

<script>
var ABBREVIATE_ABOVE = 12;

function activate(panelId) {
  var buttons = document.querySelectorAll('.tabs button');
  for (var i = 0; i < buttons.length; i++) {
    buttons[i].classList.toggle('active', buttons[i].dataset.panel === panelId);
  }
  var panels = document.querySelectorAll('.panel');
  for (var j = 0; j < panels.length; j++) {
    panels[j].classList.toggle('active', panels[j].id === panelId);
  }
}

function abbreviate(value) {
  if (Array.isArray(value)) {
    if (value.length > ABBREVIATE_ABOVE) {
      var head = value.slice(0, 3).join(', ');
      return '[' + head + ', \\u2026] (' + value.length + ' values)';
    }
    return value;
  }
  if (value && typeof value === 'object') {
    var reduced = {};
    for (var key in value) { reduced[key] = abbreviate(value[key]); }
    return reduced;
  }
  return value;
}

var lastPayload = null;

function render() {
  var payload = lastPayload;
  if (payload === null) { return; }
  var expand = document.getElementById('expand').checked;
  var shown = expand ? payload : abbreviate(payload);
  document.getElementById('result').textContent = JSON.stringify(shown, null, 2);
}

function run(panel) {
  var status = document.getElementById('status');
  status.className = '';
  status.textContent = 'Requesting\\u2026 the first land parameter query downloads datasets and may take several minutes.';

  var query = [];
  var inputs = panel.querySelectorAll('input[name], select[name]');
  for (var i = 0; i < inputs.length; i++) {
    var field = inputs[i];
    var value = field.type === 'checkbox' ? (field.checked ? 'true' : 'false') : field.value;
    query.push(encodeURIComponent(field.name) + '=' + encodeURIComponent(value));
  }

  var started = Date.now();
  fetch(panel.dataset.endpoint + '?' + query.join('&'))
    .then(function (response) { return response.json(); })
    .then(function (payload) {
      var elapsed = ((Date.now() - started) / 1000).toFixed(2);
      lastPayload = payload;
      if (payload.Warning) {
        status.className = 'error';
        status.textContent = payload.Warning + (payload.Reason ? ' (' + payload.Reason + ')' : '') +
          ' \\u2014 ' + elapsed + ' s';
      } else {
        status.textContent = 'Done in ' + elapsed + ' s';
      }
      render();
    })
    .catch(function (error) {
      status.className = 'error';
      status.textContent = 'Request failed: ' + error;
    });
}

document.addEventListener('click', function (event) {
  if (event.target.matches('.tabs button')) { activate(event.target.dataset.panel); }
  if (event.target.matches('button.run')) { run(event.target.closest('.panel')); }
});
document.getElementById('expand').addEventListener('change', render);
</script>
</body>
</html>
"""

"""

    query_page()

Return the query page with one `<option>` per catalog tag.

The options are built on every call so that tags registered after module load are visible.
"""
function query_page()
    options = join(["  <option value=\"$(tag)\"></option>" for tag in sort(YAML_TAGS)], "\n")
    return replace(PAGE_TEMPLATE, TAG_OPTIONS_PLACEHOLDER => options)
end;
```

在 `src/Server/Server.jl` 的 include 段，于 `json-grid-weather.jl` 之后加入：

```julia
include("web-page.jl");
```

**注意**：`PAGE_TEMPLATE` 使用 Julia 三引号字符串，其中 `$(TAG_OPTIONS_PLACEHOLDER)` 会在模块加载时插值成 `{{TAG_OPTIONS}}` 文本。JS 里所有 `$` 字符必须避免——本模板已确保无 `$`；Unicode 省略号与破折号用 `\\u2026` / `\\u2014` 转义写在 JS 字符串里，避免与 Julia 插值冲突。

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A10 "Server page"
```

预期：四个测试集全绿。

- [ ] **Step 5: 提交**

```bash
git add src/Server/web-page.jl src/Server/Server.jl test/server-page.jl test/runtests.jl
git commit -m "添加查询页并在请求时填充tag选项"
```

---

## Task 6: route-setup.jl 重写与端到端验证

**Files:**
- Modify: `src/Server/route-setup.jl`
- Modify: `test/server-requestor.jl`

- [ ] **Step 1: 写失败测试**

在 `test/server-requestor.jl` 的 `@testset "Server routes end to end"` 中，把这段删除：

```julia
            # an unlisted user is refused, and the Requestor reports the missing Data key
            @test_throws ErrorException Requestor.request_site_data(
                "http://localhost:$port", "stranger", tag_2d, -45, -135,
            )
```

替换为：

```julia
            # `user` 是日志标签而不是凭据：任何取值都能拿到数据。
            # 旧实现用 `user in allowed_users` 做"鉴权"，但该值来自查询参数，
            # 任何调用方都能伪造，因此本版本不再假装它是权限控制。
            other_user, other_std = Requestor.request_site_data(
                "http://localhost:$port", "stranger", tag_2d, -45, -135,
            )
            @test other_user == Float64(data_2d[1, 1])
            @test other_std == Float64(data_2d[1, 1] + 1)
```

并在同一 testset 内、`Server.down_servers!()` 之前追加对新路由与页面的端到端验证：

```julia
            # 查询页可访问，且含已登记的 tag
            page = HTTP.get("http://localhost:$port/"; retry = false, readtimeout = 10)
            @test page.status == 200
            @test occursin(tag_2d, String(page.body))

            # 新端点经真实 HTTP 可达；本夹具未登记陆面 tag，
            # 因此预期得到"数据不可用"载荷而不是异常
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
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A12 "Server routes end to end"
```

预期两类失败：`"stranger"` 仍被旧鉴权拒绝（`request_site_data` 抛 `ErrorException`）；`/gmdict.json` 返回 404，因为路由尚未注册。

- [ ] **Step 3: 实现**

把 `src/Server/route-setup.jl` 整个文件替换为：

```julia
"""

    setup_url_input_routes!(allowed_users::Vector{String} = String[])

Register the query endpoints and the query page.

`allowed_users` is retained for backward compatibility and is used only for the startup log
line. The `user` query parameter is a free-form label written to the request log, not a
credential: it arrives from the query string and any caller can set it to any value. This
server is meant for a local or trusted intranet network.

Registered routes:
- `/sitedata.json` one dataset value at one grid cell
- `/gmdict.json` land parameter dictionary at one grid cell
- `/weather.json` weather driver series at one grid cell
- `/` the query page
"""
function setup_url_input_routes!(allowed_users::Vector{String} = String[])
    isempty(allowed_users) ||
        @info "Server labels requests for: $(join(allowed_users, ", ")) (labels only, not access control)";

    route("/sitedata.json") do
        user = String(params(:user, "anonymous"));
        arttag = String(params(:tag, ""));
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);
        cyc = parse_int(params(:cycle, ""), 0);
        include_std = parse_bool(params(:include_std, ""), true);

        @info "sitedata request" user arttag lat lon cyc include_std;

        return sitedata_json(arttag, lat, lon, cyc; include_std)
    end;

    route("/gmdict.json") do
        user = String(params(:user, "anonymous"));
        gmversion = String(params(:gmversion, "gm2"));
        year = parse_int(params(:year, ""), 2020);
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);

        @info "gmdict request" user gmversion year lat lon;

        return gmdict_json(user, gmversion, year, lat, lon)
    end;

    route("/weather.json") do
        user = String(params(:user, "anonymous"));
        wdversion = String(params(:wdversion, "wd1"));
        year = parse_int(params(:year, ""), 2020);
        lat = parse_float(params(:lat, ""), 30.5);
        lon = parse_float(params(:lon, ""), 115.5);

        @info "weather request" user wdversion year lat lon;

        return weather_json(user, wdversion, year, lat, lon)
    end;

    route("/") do
        return query_page()
    end;

    return nothing
end;
```

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A12 "Server routes end to end"
```

预期：该测试集全绿，且不再有任何 POST 路由。

- [ ] **Step 5: 提交**

```bash
git add src/Server/route-setup.jl test/server-requestor.jl
git commit -m "重写路由层为四个查询路由并取消伪鉴权"
```

---

## Task 7: 移植 remove_empty_folders!

**Files:**
- Create: `src/Collector/database-remove-folder.jl`
- Modify: `src/Collector/Collector.jl`
- Modify: `test/collector.jl`

**范围说明**：只移植该工具函数并导出，**不**把它接进 `clean_database!`。`clean_database!` 当前带 `_assert_managed_path` 安全校验且被现有测试覆盖，改动它的行为超出本次范围。jianghao 分支的 `database-clean.jl` 是旧版 Collector 的实现，**不得**一并移植。

- [ ] **Step 1: 写失败测试**

在 `test/collector.jl` 末尾的 `end`（关闭最外层 `mktempdir`）之前追加：

```julia
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
    end
```

- [ ] **Step 2: 运行测试确认失败**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | tail -15
```

预期：`UndefVarError: remove_empty_folders! not defined`。

- [ ] **Step 3: 实现**

创建 `src/Collector/database-remove-folder.jl`（自 `origin/jianghao` 移植，保留其自底向上遍历与错误处理）：

```julia
"""

    remove_empty_folders!(target_dir::String)

Recursively remove empty directories inside `target_dir`, given
- `target_dir` directory to clean up

Traversal is bottom-up, so a parent that becomes empty after its children are removed is
removed as well. `target_dir` itself is kept. A missing `target_dir` is a no-op.

`clean_database!` deletes files but leaves the directories that held them, so this is
provided as a separate step rather than wired into it.
"""
function remove_empty_folders! end

function remove_empty_folders!(target_dir::String) :: Nothing
    isdir(target_dir) || return nothing

    # topdown = false visits children before their parent
    for (root, dirs, files) in walkdir(target_dir; topdown = false)
        for dir in dirs
            current = joinpath(root, dir)
            try
                isempty(readdir(current)) && rm(current)
            catch caught
                if !(caught isa SystemError && caught.errnum in (Base.Libc.EACCES, Base.Libc.ENOENT))
                    @error "Could not remove empty folder" current caught
                end
            end
        end
    end

    return nothing
end
```

在 `src/Collector/Collector.jl` 中，把 `include("database-load.jl");` 之后一行改为同时包含新文件（插在 `database-load.jl` 与 `database-sync.jl` 之间，保持字母序）：

```julia
include("database-load.jl");
include("database-remove-folder.jl");
include("database-sync.jl");
```

并在 `export` 列表中加入 `remove_empty_folders!`（按字母序插在 `local_datasets` 之后）：

```julia
export CatalogValidationError, clean_database!, configure!, dataset_cache, dataset_dir,
    dataset_found, dataset_info, dataset_path, dataset_url, download_database!,
    download_dataset!, initialize_database!, latest_datasets, load_database!,
    local_datasets, remove_empty_folders!, sync_database!, update_database!,
    validate_catalog, verify_dataset_file
```

**注意**：jianghao 原文用 `e.code`，但 `SystemError` 的字段名是 `errnum`；上面已改正。若保留 `e.code` 会在 catch 分支里再抛一个 `FieldError`。

- [ ] **Step 4: 运行测试确认通过**

```bash
julia --project=. -e 'using Pkg; Pkg.test()' 2>&1 | grep -A8 "移除空目录"
```

预期：该测试集全绿。

- [ ] **Step 5: 提交**

```bash
git add src/Collector/database-remove-folder.jl src/Collector/Collector.jl test/collector.jl
git commit -m "移植remove_empty_folders工具函数"
```

---

## Task 8: 文档、覆盖率与 CI 收尾

**Files:**
- Modify: `README.md`
- Modify: `docs/src/API.md`
- Modify: `/Users/haomin/Desktop/code/Emerald/GriddingMachine_Reaserach/论文/GriddingMachine_v0.5.0_ReleaseNotes草稿.md`

- [ ] **Step 1: 更新 README 的 API 表格与新增 Server 章节**

把 `README.md` 中 API 表格的 Server 行改为：

```markdown
| Server      | Serve site-level data and a query page over HTTP      | v0.5         |
```

在 "Migrating from v0.4 to v0.5" 章节之前插入：

```markdown
## Query server

`GriddingMachine.Server` serves a small query page and three JSON endpoints:

```julia
julia> using GriddingMachine.Collector, GriddingMachine.Server;
julia> Collector.update_database!();
julia> Server.setup_url_input_routes!();
julia> Server.up_servers!(5055);
```

Then open `http://localhost:5055/`, or call the endpoints directly:

| Endpoint | Query parameters |
|:---------|:-----------------|
| `/sitedata.json` | `tag`, `lat`, `lon`, `cycle`, `include_std`, `user` |
| `/gmdict.json` | `gmversion` (`gm1`/`gm2`), `year`, `lat`, `lon`, `user` |
| `/weather.json` | `wdversion` (`wd1`), `year`, `lat`, `lon`, `user` |

Stop the server with `Server.down_servers!()`.

**This server is meant for a local or trusted intranet network.** It binds `0.0.0.0` and has
no access control: the `user` parameter is a label written to the request log, not a
credential, and any caller can set it to any value. `/gmdict.json` and `/weather.json`
download whole dataset collections on first use, which can mean hundreds of megabytes per
request. Do not expose this server to an untrusted network.

Missing values are encoded as `-9999` in every response, because JSON has no NaN literal.
When a query needs datasets that are not registered in the local catalog, the response names
them under `MissingTags` instead of failing.
```

- [ ] **Step 2: 更新 docs/src/API.md**

在文件末尾的 `## Requestor` 段之后追加：

```markdown
## Server

```@docs
Server.sitedata_json
Server.gmdict_json
Server.weather_json
Server.query_page
Server.setup_url_input_routes!
Server.up_servers!
Server.down_servers!
```
```

并在 `## Collector` 的 `@docs` 块中加入一行：

```
Collector.remove_empty_folders!
```

- [ ] **Step 3: 本地构建文档确认无失败**

`docs-build` 与 `documenter/deploy` 是 main 的必需检查，`@docs` 块引用不存在的符号会导致构建失败。

```bash
julia --project=docs/ -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=docs/ docs/make.jl 2>&1 | tail -15
```

预期：出现 `RenderDocument: rendering document`，无 `Error`；结尾 `Skipping deployment` 属正常（非 CI 环境）。

- [ ] **Step 4: 跑全量测试并生成覆盖率**

```bash
julia --project=. -e 'using Pkg; Pkg.test(; coverage=true)' 2>&1 | grep -E "Test Summary|\| *[0-9]|tests passed"
```

预期：全部通过，总数约 270 项（当前 193 + 新增约 80）。

```bash
julia --project=/tmp/covenv -e '
using Coverage
cov = process_folder("src")
c, l = get_summary(cov)
println("总覆盖率: ", c, "/", l, " = ", round(100*c/l; digits=2), "%")
for f in cov
    cc, ll = get_summary(f)
    ll == 0 && continue
    println(rpad(replace(f.filename, "src/"=>""), 40), lpad("$cc/$ll", 9), lpad("$(round(100*cc/ll; digits=1))%", 8))
end' 2>&1 | grep -vE "Info:|└|┌"
```

验收标准：总覆盖率 ≥ 96.92%；`src/Server/` 与 `src/Collector/database-remove-folder.jl` 下每个文件 ≥ 90%。若某文件偏低，补测未覆盖分支后重跑。

清理覆盖率产物（`.gitignore` 已忽略 `*.cov`，但仍应清掉以免干扰后续统计）：

```bash
find . -name "*.cov" -delete
```

- [ ] **Step 5: 更新 release notes 草稿**

在 `/Users/haomin/Desktop/code/Emerald/GriddingMachine_Reaserach/论文/GriddingMachine_v0.5.0_ReleaseNotes草稿.md` 的 `### Dependencies and CI` 之前插入：

```markdown
### Query server

`Server` now serves a query page at `/` alongside three JSON endpoints: `/sitedata.json`
(one dataset value at one grid cell), `/gmdict.json` (land parameter dictionary) and
`/weather.json` (weather driver series). The page queries those same endpoints from the
browser, so the interface and the API share one code path and there are no form-post routes.

- `/sitedata.json` accepts an optional `include_std` flag; when it is false the `Stdv` key is
  set to `null` rather than removed, so `Requestor.request_site_data` keeps working.
- The stray `Nothing` field has been removed from `/sitedata.json` responses.
- Every response encodes `NaN` as `-9999`. A query whose datasets are not registered in the
  local catalog returns them under `MissingTags` instead of raising.
- Failures report a stable `Reason` category; exception text stays in the server log.
- `Collector.remove_empty_folders!` removes empty directories left behind by `clean_database!`.

The server binds `0.0.0.0` and performs no access control. The `user` parameter is a log
label, not a credential. It is meant for a local or trusted intranet network.
```

- [ ] **Step 6: 提交并推送**

```bash
cd /Users/haomin/Desktop/code/Emerald/GriddingMachine.jl
git add README.md docs/src/API.md
git commit -m "补充Server查询服务文档"
git -c http.version=HTTP/1.1 push origin release/v0.5.0

cd /Users/haomin/Desktop/code/Emerald/GriddingMachine_Reaserach
git add 论文/GriddingMachine_v0.5.0_ReleaseNotes草稿.md
git commit -m "release notes补充Server查询服务"
git -c http.version=HTTP/1.1 push origin main
```

- [ ] **Step 7: 确认三平台 CI 与 codecov**

```bash
export PATH="$HOME/.local/bin:$PATH"
sleep 300
gh pr checks 90 --repo CliMA/GriddingMachine.jl
```

验收标准：7 项全部 `pass`，其中必需的 `docs-build` 与 `documenter/deploy` 必须通过；`codecov/project` 不得回退为 fail。

Windows 侧需特别留意路径分隔符：新增测试若比较路径字符串，一律先 `normpath`（本计划中的新测试不比较路径，但若补测时引入，须遵守此约定）。

若某平台失败，取失败详情后再修：

```bash
gh run view <run-id> --repo CliMA/GriddingMachine.jl --log-failed | grep -A8 -iE "Test Failed|Expression:"
```

---

## 自查结果

**规格覆盖核对**（对照 `docs/superpowers/specs/2026-09-01-server-web-design.md`）：

| 规格章节 | 对应任务 |
|---|---|
| 4 文件结构 | Task 1（responses）、3、4、5、6 |
| 5.1 sitedata 契约与 include_std、移除 Nothing、目录刷新不变 | Task 2 |
| 5.2 gmdict 契约 | Task 3 |
| 5.3 weather 契约 | Task 4 |
| 5.4 `/` 页面 | Task 5 |
| 5.5 不新增 artifact/request 端点 | Task 6（只注册 4 个路由） |
| 5.6 NaN 编码、错误不泄露、缺数据语义、错误分类机制 | Task 1（实现）+ Task 3/4（验证） |
| 6 缺陷 1（空下拉框） | Task 5 测试集「tag 选项在请求时填充」 |
| 6 缺陷 2（YAML_FILE_TIME） | Task 2（不移植该限流逻辑） |
| 6 缺陷 3（parse Bool） | Task 1 测试 + Task 6 端到端 `include_std=1` |
| 6 缺陷 4（gm3/gm4） | Task 5 测试集「只列出受支持的版本」+ Task 3 unsupported |
| 6 缺陷 5（脆弱替换） | Task 5（占位符 + 断言无残留） |
| 6 缺陷 6（重复路由） | Task 6 |
| 6 缺陷 7（POST 绕过鉴权） | Task 6（无 POST 路由） |
| 6 缺陷 8（泄露异常） | Task 3 测试「不含 Stacktrace / 临时路径」 |
| 6 缺陷 9（两套模板） | Task 5 |
| 6 缺陷 10（src 内脚本） | Task 8（用法写入 README/API.md，不建脚本） |
| 6 缺陷 11（无测试） | Task 1、3、4、5、6、7 |
| 6 缺陷 12（Nothing 字段） | Task 2 |
| 7 网页与交互 | Task 5 |
| 8 测试策略 9 项 | 1→Task 3/4；2→Task 3/4 缺失分支；3→Task 3/4；4→Task 3；5→Task 2；6→Task 1/6；7→Task 5；8→Task 6；9→Task 1/3/4 |
| 9 remove_empty_folders! | Task 7 |
| 10 兼容性 | Task 2（契约）、Task 6（up_servers! 不改）、Task 8（文档标注风险） |
| 11 交付 | Task 8 |

无未覆盖的规格条目。

**类型与命名一致性核对**：`encode_missing` / `parse_float` / `parse_int` / `parse_bool` / `warning_payload(reason, fields::AbstractDict)` / `missing_datasets_payload(absent, fields::AbstractDict)` / `classify_error` / `required_tags` / `missing_tags` / `REASON_*` / `query_page` / `TAG_OPTIONS_PLACEHOLDER` / `SUPPORTED_GM_VERSIONS` / `SUPPORTED_WD_VERSIONS` 在定义处与各调用处签名一致；两个载荷构造函数均以 `AbstractDict` 接收上下文（不使用关键字展开，因为上下文键是 String）。

**已修正的一处上游缺陷**：jianghao 的 `remove_empty_folders!` 用 `e.code`，而 `SystemError` 的字段是 `errnum`，原写法会在 catch 分支内再抛 `FieldError`。Task 7 已改为 `caught.errnum`。

**执行顺序约束**：Task 1 必须先完成（其余任务都依赖 `responses.jl`）。Task 3 必须在 Task 4 之前（`test/server-endpoints.jl` 的夹具在 Task 3 建立）。Task 6 必须在 Task 3、4、5 之后（路由引用三个 json 函数与 `query_page`）。Task 7 与 Server 无依赖，可任意时点插入。Task 8 最后。
