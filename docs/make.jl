using Documenter
using GriddingMachine
using Literate
using PkgUtility




# define default docs pages
pages = Pair{Any,Any}[
    "Home" => "index.md",
    "API"  => "API.md"  ,
]




# add preview pages
gen_preview = false;
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

@info "Pages to generate:"
pretty_display!(pages);




# format the docs
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
    assets = ["assets/favicon.ico"]
)




# build the docs
makedocs(
    sitename = "GriddingMachine",
    format = format,
    clean = false,
    modules = [GriddingMachine],
    pages = pages,
)




# function to replace strings (copied from Yujie-W/PAGES)
# TODO move to PkgUtility.jl later
function replace_html(file_name::String)
    list_str   = readlines(file_name);
    file_write = open(file_name, "w");
    for i in eachindex(list_str)
        list_str[i] = replace(list_str[i], "<p>&lt;details&gt; &lt;summary&gt;" => "<details><summary>");
        list_str[i] = replace(list_str[i], "&lt;/summary&gt;</p>" => "</summary>");
        list_str[i] = replace(list_str[i], "<p>&lt;/details&gt;</p>" => "</details>");
        write(file_write, list_str[i] * "\n");
    end

    return nothing
end




# Replace the strings
file_name = joinpath(@__DIR__, "build/API.html");
if isfile(file_name)
    replace_html(file_name);
else
    file_name = joinpath(@__DIR__, "build/API/index.html");
    if isfile(file_name)
        replace_html(file_name);
    else
        @warn "No file found to work on, please check file names";
    end
end




# deploy the docs to Github gh-pages
deploydocs(
    repo = "github.com/CliMA/GriddingMachine.jl.git",
    target = "build",
    devbranch = "main",
    push_preview = true,
)
