using Pkg
pkg"activate .."

using Documenter

# push the source directory into Julia's load path
push!(LOAD_PATH, "../src/")
using NeuralVerifier

# make the documenter site
makedocs(
    sitename = "NeuralVerifier.jl",
    authors = "Jay Morgan",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Function Reference" => Any[
            "Activations" => "ref/activations.md",
            "Layers" => "ref/layers.md"
        ]
    ]
)


deploydocs(
    repo = "github.com/jaypmorgan/NeuralVerifier.jl.git",
)
