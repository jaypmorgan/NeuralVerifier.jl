# NeuralVerifier

Verification of Neural Networks.

## Installation

### Prerequisites 

NeuralVerifier uses the [Z3](https://github.com/Z3Prover/z3) as the backend SMT solver. To run NeuralVerifier, this [module](https://pypi.org/project/z3-solver/) must be installed via python's pip:

```bash
pip install z3-solver
```

After the installation of Z3 is complete, you will be ready to install this library. Installation can be made either from the REPL or from a script using the normal methods.

### REPL

```julia
] add git@github.com:jaypmorgan/NeuralVerifier.jl.git
```

### Script

```julia
using Pkg
Pkg.add("git@github.com:jaypmorgan/NeuralVerifier.jl.git")
```

## Usage

Once installed, you can import the library:

```julia
using NeuralVerifier;
```

And create an SMT encoding of an existing Neural Network:

```julia
encoding(x) = begin
    y = dense(x,
              neural_network[1].W |> Tracker.data,
              neural_network[1].b |> Tracker.data) |> relu;
    y = dense(y,
              neural_network[2].W |> Tracker.data,
              neural_network[2].b |> Tracker.data) |> softmax;
end
```

In this example, we have created a function `encoding` that takes a $x$ argument -- the input to the neural network. This function creates a very basic two-layer fully-connected network using the existing weights and biases from the _real_ network. Moreover, we may apply the non-linearity functions to each layer (such as 'relu' or 'softmax') in the usual manner.

We have used a function to create the encoding to allow us to re-use the encoding under different constraints in the SMT solver, instead of having to re-write the encoding process multiple times.

While in this example, we are using [FluxML](https://fluxml.ai) network (using Tracker.data to extract to the matrices from the computational graph), it is feasible -- but un-tested -- to use other arbitrary matrices from other ML libraries.

We have thus far included support for the following layers:

- Dense/Fully-connected (dense)
- 1D/2D convolutions (conv1D/conv2D respectively)
- Pooling operations (maxpool/avgpool)
- Matrix flattening (flatten)

And the following non-linearites:

- Sigmoid (sigmoid)
- ReLU (relu)
- Softmax (softmax)

While this covers a suprising number of basic configurations, contributions of more implementations are always welcome!
