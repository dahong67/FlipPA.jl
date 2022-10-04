using FlipPA
using Documenter

DocMeta.setdocmeta!(FlipPA, :DocTestSetup, :(using FlipPA); recursive=true)

makedocs(;
    modules=[FlipPA],
    authors="David Hong <dahong67@wharton.upenn.edu> and contributors",
    repo="https://github.com/dahong67/FlipPA.jl/blob/{commit}{path}#{line}",
    sitename="FlipPA.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dahong67.github.io/FlipPA.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dahong67/FlipPA.jl",
    devbranch="master",
)
