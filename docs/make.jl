using Documenter
using GriddingMachine


# define default docs pages
pages = Pair{Any,Any}[
    "Home" => "index.md",
    "API"  => "API.md"  ,
]


# format the docs
mathengine = MathJax(
    Dict(
        :TeX => Dict(
            :equationNumbers => Dict(:autoNumber => "AMS"),
            :Macros => Dict()
        )
    )
);

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
    assets = ["assets/favicon.ico"]
);


# build the docs
makedocs(
    sitename = "GriddingMachine",
    checkdocs = :none,
    clean = false,
    format = format,
    modules = [GriddingMachine],
    pages = pages,
);


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
);
