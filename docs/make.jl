using Documenter
using GlobalCanopy

pages = Any[
    "Home" => "index.md",
    "API"  => "API.md"
    ]


mathengine = MathJax(Dict(
    :TeX => Dict(
        :equationNumbers => Dict(:autoNumber => "AMS"),
        :Macros => Dict(),
    ),
))

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
)

makedocs(
    sitename = "GlobalCanopy",
    format = format,

    clean = false,
    modules = [GlobalCanopy],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/GlobalCanopy.jl.git",
    target = "build",
    push_preview = true,
)
