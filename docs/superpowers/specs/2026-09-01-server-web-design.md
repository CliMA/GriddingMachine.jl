# GriddingMachine.jl Server 网页版设计

- 日期：2026-09-01
- 目标分支：`release/v0.5.0`（随 PR #90 一起合入 main，作为 0.5.0 的一部分）
- 参考实现：`origin/jianghao`（本设计重新实现，不直接合并该分支）

## 1. 背景与目标

`origin/jianghao` 分支实现了一套 Server 网页版：4 个 JSON 端点 + 一个三页签 HTML 表单页，约 750 行。功能方向是对的，但实现存在若干真实缺陷（见第 6 节），需要重做而非直接合并。

目标：在 main 上提供一个可用的本地/内网数据查询网页，能力对齐 jianghao，并修掉其已知缺陷。

## 2. 非目标

- 不面向公网。本服务定位为本地或组内可信网络使用。
- 不做用户体系或权限模型。
- 不改变 `Collector` / `Indexer` 的任何现有行为。
- 不触碰论文结论。论文明确将 Server/Requestor 排除在验证范围外；论文引用的是不可变 tag `griddingmachine-paper-2026-v1`，本设计不影响其可追溯性。

## 3. 已确认的决策

| 项 | 决定 |
|---|---|
| 部署场景 | 本地 / 组内可信网络 |
| 能力范围 | 单点读取、陆面参数字典、气象驱动三块全做；数据缺失时返回明确说明而非异常 |
| 交互形态 | 页面内异步查询（`fetch`），不做表单跳转，不设 POST 结果路由 |
| 绑定地址 | 保持 `0.0.0.0`，`up_servers!` 不改（非破坏性） |
| 访问控制 | 不做鉴权；`user` 参数降级为纯日志字段，并在代码与文档中明确标注它不是权限控制 |
| 版本 | 随 0.5.0 发布 |

## 4. 文件结构

```
src/Server/
  Server.jl              模块入口（现有，增加 include）
  responses.jl           新增：共享响应构造与参数解析
  json-site-data.jl      现有，增加可选 include_std
  json-grid-dict.jl      新增：gmdict_json
  json-grid-weather.jl   新增：weather_json
  web-page.jl            新增：单一 HTML 模板
  route-setup.jl         现有，改薄
  route-up-down.jl       现有，不改
```

一个文件一个职责。jianghao 的 `unified-form.jl`（280 行裸 HTML 字符串）与 `web-forms.jl`（Genie HTML DSL 组件）两套并存的模板收敛为 `web-page.jl` 一套。`route-setup.jl` 由 181 行降至约 50 行，因为 6 个路由中重复的参数解析/鉴权样板与 3 个 POST `_result` 路由全部消除。

`responses.jl` 提供：

- `encode_missing(x)`：把 `NaN` 编码为 `-9999`，非原地，标量与数组统一处理
- `success_payload(fields...)` / `warning_payload(reason, fields...)`：统一响应外形
- `query_float(name, default)` / `query_int(...)` / `query_bool(...)`：宽松参数解析，解析失败退回默认值而不抛异常

## 5. 端点契约

### 5.1 `GET /sitedata.json`（现有，契约保持兼容）

参数：`tag`、`lat`、`lon`、`cycle`、`include_std`（新增，默认 `true`）、`user`（日志用）

成功响应：

```json
{"Latitude": -45, "Longitude": -135, "Cycle": 0,
 "Data": [...], "Stdv": [...]}
```

`include_std=false` 时返回 `"Stdv": null`，**不删除该键**。原因：`Requestor.request_site_data` 无条件访问 `json_dict["Stdv"]`，删键会导致 `KeyError`；返回 `null` 时 `Requestor` 已能正确透传（现有测试覆盖 `null_stdv` 分支）。默认 `true` 时数值行为与当前完全一致。

**移除 `"Nothing": null` 字段**。现有响应体中含一个名为 `"Nothing"`、值永为 `null` 的字段，系遗留调试字段，无任何语义。`Requestor` 不读取它。本次一并移除，并同步调整现有测试中对它的断言。该端点在 README 中标为 `Experimental`，0.5.0 是清理它的合适时机。

**目录刷新行为保持不变**：该端点现有逻辑在 tag 不在 `YAML_TAGS` 中时会调用 `update_database!()` 刷新目录，这一行为不改动。新增的两个端点**不**做目录刷新（见 5.6 节）。

### 5.2 `GET /gmdict.json`（新增）

参数：`gmversion`（仅接受 `gm1` / `gm2`）、`year`、`lat`、`lon`、`user`

```json
{"User": "anonymous", "GMVersion": "gm2", "Year": 2020,
 "Latitude": 40.03, "Longitude": -105.55, "GridDict": {...}}
```

键名不使用空格（jianghao 用的是 `"GM Version"` / `"GM Dict"`），便于客户端访问。

### 5.3 `GET /weather.json`（新增）

参数：`wdversion`（仅接受 `wd1`）、`year`、`lat`、`lon`、`user`

```json
{"User": "anonymous", "WDVersion": "wd1", "Year": 2020,
 "Latitude": 40.03, "Longitude": -105.55, "WeatherDrivers": {...}}
```

### 5.4 `GET /`

返回 HTML 页面。

### 5.5 不新增的端点

不实现 `/artifact.json` 与 `/request.json`。二者在 jianghao 中是彼此的完整复制粘贴，且与 `/sitedata.json` 功能重合；其唯一独有能力 `include_std` 已并入 `/sitedata.json`。网页的 "Artifact Data" 页签直接调用 `/sitedata.json`。

### 5.6 三条统一语义

**缺失值编码**：`NaN` 一律编码为 `-9999`，三个端点使用同一个 `encode_missing`。

**错误不泄露内部细节**：完整异常只写服务端日志，响应体只含稳定的类别信息：

```json
{"Warning": "Your request cannot be completed",
 "Reason": "unsupported version",
 "User": "anonymous", "Latitude": 40.03, "Longitude": -105.55}
```

`Reason` 取值限定为：`unsupported version`、`no land at target grid`、`grid is not vegetated`、`datasets unavailable`、`internal error`。

**数据不可用要说清缺什么**：当所需 tag 未登记在本地目录中时：

```json
{"Warning": "Required datasets are not available",
 "MissingTags": ["PATM_ERA5_1X_1H_2020_V1", "PPT_ERA5_1X_1H_2020_V1"],
 "Hint": "These tags are not registered in the local catalog",
 "User": "anonymous", "WDVersion": "wd1", "Year": 2020}
```

实现方式：先构造 `LandDatasetLabels(gmversion, year)` 或 `WeatherDriverLabels(wdversion, year)`，从其 `tag_*` 字段枚举出所需的全部 tag（gm1/gm2 各 14 个，wd1 为 8 个），逐个用 `Collector.dataset_found` 检查，把缺失项收集齐后一次返回，而不是让第一个缺失的 tag 抛出异常。这两个端点**不**调用 `update_database!()`：下载与刷新目录属于 `Collector` 的职责，网页查询不应隐式触发远程刷新。

这条对 `wd1` 尤其重要：论文记录显示 2020 年 `wd1` 的 8 个 ERA5 条目只登记了机构 FTP、未提供 `SIZE`/`SHA256`，校外无法访问。界面上这个按钮必须给出可读的回答，而不是假装可用或抛出天书。

**错误分类的实现方式**：`grid_dict` 在目标格点无陆地或无植被时抛出 `ErrorException`，消息分别为 `The target grid does not contain land!` 与 `The target grid is not vegetated!`。本设计采用**子串匹配**将其映射到 `no land at target grid` / `grid is not vegetated`，无法识别时一律归为 `internal error`。这是一个自觉的取舍：它依赖上游错误消息的文本，但好于在网页层重复一遍陆地掩膜与 LAI 的判断逻辑（会造成双块逻辑漂移）。第 8 节的测试会同时钉住这两条映射，上游消息一变即报错。

## 6. 修正 jianghao 的已知缺陷

以下问题均已在 `origin/jianghao` 源码中核实：

| # | 缺陷 | 位置 | 处理 |
|---|---|---|---|
| 1 | tag 下拉框永远为空：`GM_TAGS = sort(YAML_TAGS)` 在 `include` 时求值，而 `YAML_TAGS` 此时为空数组（由 `load_database!` 运行时填充） | `web-forms.jl:10` | 改为在 `/` 路由处理函数内、每次请求时读取当前 `Collector.YAML_TAGS` |
| 2 | `YAML_FILE_TIME` 从未定义，走到"未知 tag"分支即 `UndefVarError` | `json-artifact.jl:18,21,24` | 不移植该限流逻辑；未知 tag 直接返回警告载荷 |
| 3 | `parse(Bool, params(:include_std, "true"))` 遇 `?include_std=1` 抛异常 | `route-setup.jl` | 用 `query_bool` 宽松解析，接受 `true/false/1/0/yes/no`，无法识别时用默认值 |
| 4 | 下拉框提供 `gm3`/`gm4`，但 `LandDatasetLabels` 仅支持 `gm1`/`gm2`，选中必报错 | `web-forms.jl:14` | 只提供受支持的版本；服务端校验后返回 `Reason: unsupported version` |
| 5 | 模板注入依赖精确空白与注释的长字符串 `replace`，模板一改即静默失效 | `route-setup.jl` `/` 路由 | 改用 `{{TAG_OPTIONS}}` 占位符 |
| 6 | `/request.json` 与 `/artifact.json` 为完整复制粘贴；6 个路由重复同一套样板 | `route-setup.jl` | 只保留一个端点；样板收敛进 `responses.jl` |
| 7 | POST 结果路由完全不校验，硬编码 `"Anonymous"` 直接返回数据 | `route-setup.jl` | 采用页面内异步方案后不存在 POST 路由 |
| 8 | `catch e` 把 `string(e)` 返回客户端，泄露路径与堆栈 | `json-gmdict.jl`、`json-weather.jl` | 异常只进日志，响应只含 `Reason` 类别 |
| 9 | 两套 HTML 模板并存，职责重叠 | `unified-form.jl` + `web-forms.jl` | 收敛为 `web-page.jl` |
| 10 | `example_server.jl` 放在 `src/Server/` 内，但它不是模块代码 | `src/Server/example_server.jl` | 不移植；用法写入 README 与 `docs/src/API.md` |
| 11 | 无任何测试 | — | 见第 8 节 |
| 12 | `"Nothing": null` 遗留调试字段 | `json-site-data.jl` | 移除，并同步调整现有测试断言（见 5.1 节） |

## 7. 网页与交互

单一 HTML 模板，三个页签：Artifact Data / GM Dictionary / Weather Data。表单提交由 JavaScript 拦截，`fetch()` 调用对应 JSON 端点，结果在同页渲染。

**无外部依赖、无 CDN**。组内机器可能没有外网，引用 CDN 会使页面直接失效。JavaScript 约 60 行，纯原生。

**tag 选择**：目录约有 1179 个 tag，`<select>` 需滚动上千项。改用 `<input list="gm-tags">` + `<datalist>`，可键入 `ELEV` 直接筛选，浏览器原生支持，无需 JS 库。

**结果展示**：状态行（成功 / 警告）+ 耗时 + 可滚动的格式化 JSON。`gmdict` 返回 34 个键、其中多个为 366 长度数组，默认将长度大于 12 的数组折叠为 `[v1, v2, …] (366 values)`，提供"展开完整数组"开关。

**loading 状态**：`gmdict` 首次请求可能触发约 184 MB 下载，需显示"首次请求需下载数据集，可能耗时数分钟"，避免看起来像卡死。

## 8. 测试策略

关键前提：上一轮已建成 `test/fixtures.jl` 中的 `stage_datasets!`，可把任意 tag 以极小分辨率（4×2）落成 NetCDF 并登记进临时目录，使 `read_dataset(tag)` 与 `download_dataset!(tag)` 完全离线解析。`test/grid-from-tags.jl` 已用它预置了 14 个 gm2 陆面 tag 与 8 个 wd1 气象 tag。同一套夹具直接复用，**无需下载 184 MB 即可端到端测试三个端点**。

| # | 测试 | 覆盖目标 |
|---|---|---|
| 1 | 三个端点在完整夹具下返回预期载荷结构与数值 | 主路径 |
| 2 | 只登记部分所需 tag，断言 `MissingTags` 精确等于缺失集合且不抛异常 | 第 5.6 节缺数据语义 |
| 3 | `gmversion=gm9` / `wdversion=wd9` 返回 `Reason: unsupported version` | 缺陷 4 |
| 4 | 响应体不含 `Stacktrace` 字样、不含临时目录路径 | 缺陷 8 回归 |
| 5 | `include_std=false` 时 `Stdv` 为 `null`，且 `Requestor.request_site_data` 仍能解析该响应 | 契约保护 |
| 6 | `include_std` 取 `1` / `yes` / 乱码 均不抛异常 | 缺陷 3 |
| 7 | `GET /` 返回 200，且页面内含已登记的 tag 名 | 缺陷 1 回归 |
| 8 | 启动 Genie 服务，经真实 HTTP 请求 `/gmdict.json` 并解析 | 端到端 |
| 9 | `NaN` 输入在三个端点均编码为 `-9999` | 第 5.6 节 |

所有测试只写临时目录，不访问外网（网络路径一律用本地 HTTP 端点或注入式 downloader），与现有 193 项测试的约定一致。

目标：新增文件覆盖率打满，仓库总覆盖率不低于当前的 96.92%。

## 9. 附带纳入的范围

`origin/jianghao` 中还有一个 main 缺失的 Collector 功能：`src/Collector/database-remove-folder.jl` 提供 `remove_empty_folders!(target_dir)`（32 行），用于清理空目录。既然本次目标是把各分支代码归并到 main，一并纳入：移植该文件、在 `Collector.jl` 中 include、加入导出列表，并补测试（空目录被删除、非空目录保留、清理范围限定在临时根目录内）。

## 10. 兼容性与风险

**不破坏现有行为：**

- `/sitedata.json` 契约保持兼容，`Requestor` 不受影响（第 8 节测试 5 守护）
- `up_servers!` 完全不改，仍绑 `0.0.0.0`，非破坏性
- 不引入新依赖；`route` / `params` / `up` / `down` 均为现有用法
- `Collector` / `Indexer` 行为不变

**本设计自身引入的一处脆弱点**：错误分类依赖上游错误消息的子串匹配（已在 5.6 节如实记录为自觉取舍）。缓解手段：测试同时钉住两条映射，上游消息一变即报错。

**无鉴权且绑 `0.0.0.0` 的安全前提**：README 中写明面向可信内网，并注明 `gmdict` 端点可触发大流量下载；`user` 参数在代码注释与文档中明确标注为日志标签、不是权限控制；Server / Requestor 在 README 中保持 `Experimental` 标注。

## 11. 交付

- 分支：`release/v0.5.0`（现有 PR #90）
- 版本：0.5.0，不单独升版本号
- 同步更新：README 的 Server 章节（记录端点、用法与安全前提）、`docs/src/API.md`
- Release notes 草稿需追加 Server 网页版一节

工作量估计：新增源码约 350 行（含 HTML 模板约 180 行）+ 测试约 200 行；相对 jianghao 的实现净减少约 420 行重复代码。
