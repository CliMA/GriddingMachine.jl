using Documenter
using GriddingMachine
using Literate

pages = Any[
    "Home" => "index.md",
    "API"  => "API.md"  ,
]

gen_preview = true;
gen_dir     = joinpath(@__DIR__, "src/generated");
rm(gen_dir, force=true, recursive=true);
mkpath(gen_dir);

if gen_preview
    filename    = joinpath(@__DIR__, "src/preview.jl");
    script      = Literate.script(filename, gen_dir);
    code        = strip(read(script, String));
    mdpost(str) = replace(str, "@__CODE__" => code);
    Literate.markdown(filename, gen_dir, postprocess=mdpost);
    push!(pages, "Data Preview" => "generated/preview.md");
end

@show pages;

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
    devbranch = "main",
    push_preview = true,
)
