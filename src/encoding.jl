module Encoding

using PyCall
using ..NeuralVerifier

include("encoding/activations.jl");
include("encoding/layers.jl");
include("encoding/utils.jl");
include("encoding/analysis.jl");

end # Encoding
