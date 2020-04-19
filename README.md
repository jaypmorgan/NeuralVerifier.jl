# NeuralVerifier

Verification of Neural Networks in Julia.

## Installation

### Prerequisites 

NeuralVerifier uses [Z3](https://github.com/Z3Prover/z3) as the backend SMT solver. To run NeuralVerifier, this [module](https://pypi.org/project/z3-solver/) must be installed via python's pip interface:

```bash
pip install z3-solver
```

After the installation of Z3, you will be ready to install this library. Installation can either be made from the REPL or a script.

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

The normal process of using framework is as follows:

1. Create an SMT encoding of an existing network
2. Instantiate an SMT solver
3. Add your encoding and specifications to check to the solver
4. Check for satisfiability

### Generating an Encoding

Create an SMT encoding of an existing Neural Network:

```julia
# build an network with FluxML
neural_network = Chain(
	Dense(30, 20, Flux.relu),
	Dense(20, 1);  # scalar output -- i.e. for regression

# train the network...

# generate the SMT encoding of the _trained_ network
encoding(x) = begin
	detach(x) = Tracker.data(x)
    y = dense(x,
              neural_network[1].W |> detach,
              neural_network[1].b |> detach) |> relu;
    y = dense(y,
              neural_network[2].W |> detach,
              neural_network[2].b |> detach);
end
```

In this example, we've created a function called `encoding` that takes a argument -- the input to the neural network. This function creates a very basic two-layer fully-connected network using the existing weights and biases from the _real_ network. Moreover, we may apply the non-linearity functions to each layer (such as 'relu' or 'softmax') in the usual manner.

We have used a function to create the encoding to allow us to re-use the encoding under different constraints in the SMT solver, instead of having to re-write the encoding process multiple times.

However, for clarity, here is another way of accomplishing the same goal with a more function composition centric writing style:

```julia
W_1 = Tracker.data(neural_network[1].W)
b_1 = Tracker.data(neural_network[1].b)
W_2 = Tracker.data(neural_network[2].W)
b_2 = Tracker.data(neural_network[2].b)

y = relu(dense(x, W_1, b_1))
y = softmax(dense(y, W_2, b_2))
```

In these examples, we are using [FluxML](https://fluxml.ai) network (using Tracker.data to extract the matrices from the computational graph), it is feasible -- but untested -- to use other arbitrary matrices from other ML libraries.

### Verify Against a Constraint

As per the installation requirements, this framework comes with Z3 and provides basic access to the python-api. This means that, using our encoding of the neural network, we can create and check for satisfiability of specifications directly in Julia.

To begin, we must first create our solver:

```julia
solver = Solver()
```

And add some variables that represent each dimension of the input

```julia
n_dims = 30
input = [Z3Float("x$i") for i = 1:n_dims]
```

Notice how each input dimension was given a different name (i.e. x1, x2, and so on). If we didn't give the variable a unique name, it would have been overwritten in the Z3 solver.

We can then apply some additional constraint, such as the input must be within a particular range:

```julia
# all dimensions must be within the range (-10, 10)
for i = 1:n_dims
    add!(solver, input[i] < 10 $\land$ > -10)
    # or add!(solver, And(input[i] < 10, input[i] > -10)
end
```

And add out search condition (just another constraint).

```julia
# Is there some input within the range(-10, 10) that results in an output > 100
add!(solver, encoding(input) > 100)
```

Finally, we can start the verification process and check whether the constraints are satisfiable.

```julia
check(solver)  # probably will take a while for very large networks
print(m.is_sat)
```

In summary our example script is as follows:

```julia
# build an network with FluxML
INPUT_SIZE  = 30
HIDDEN_SIZE = 50

neural_network = Chain(
	Dense(INPUT_SIZE, HIDDEN_SIZE, Flux.relu),
	Dense(HIDDEN_SIZE, 1);  # scalar output -- i.e. for regression

# train the network...

# generate the SMT encoding of the _trained_ network
encoding(x) = begin
	detach(x) = Tracker.data(x)
    y = dense(x,
              neural_network[1].W |> detach,
              neural_network[1].b |> detach) |> relu;
    y = dense(y,
              neural_network[2].W |> detach,
              neural_network[2].b |> detach);
end

# instantiate our solver and add input variables
solver = Solver()
input  = [Z3Float("x$i") for i = 1:INPUT_SIZE]
for i = 1:n_dims
    add!(solver, input[i] < 10 $\land$ > -10)
end

# add our final constraint to check for
add!(solver, encoding(input) > 100)

# check for satisfiability and print output
check(solver)
print(m.is_sat)
```

## Functionality & Support

We have thus far included support for the following layers:

- Dense/Fully-connected (dense)
- 1D/2D convolutions (conv1D/conv2D respectively)
- Pooling operations (maxpool/avgpool)
- Matrix flattening (flatten)

And the following non-linearites:

- Sigmoid (sigmoid -- hidden non-linearities currently uses limited precision that is not yet production quality)
- ReLU (relu)
- Softmax (softmax)

While this covers a suprising number of basic configurations, contributions of more implementations are always welcome!
