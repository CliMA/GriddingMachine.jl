using Documenter
using GriddingMachine

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
    sitename = "GriddingMachine",
    format = format,

    clean = false,
    modules = [GriddingMachine],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/GriddingMachine.jl.git",
    target = "build",
    push_preview = true,
)
