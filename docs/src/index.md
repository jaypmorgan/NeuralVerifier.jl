# NeuralVerifier.jl Documentation

```@contents
```

Verification is the process of building symbolic representations of reachable program states. In the context of verification of machine learning models, the symbolic representation of the model (nural network) may be a first-order formula that represents the decision process of said model.

**Dynamic symbolic execution** -- using SMT solvers for checking path feasibility (activation of nodes)

**Symbolic Software Model Checking** -- SMT solvers to bridge the gap from programs with large or unbouded state spaces into small finite state abstractions.

**Scalable static analysis** -- functional program verification to SMT solvers.

For loops and recursion, we use bounded recursion and bounded loops. This simply means that we limit the depth of the recursive calls by a fixed number. Likewise, bounded loops are traversed by a fixed number of iterations. In these cases there is a mapping from programs to logical formulas that summarise the input-output relations of the program. The mapping uses the _single static assignment_ (SSA) representation of programs. The main idea is to unfold bounded loops and procedure calls then create a time-stamped version of the program variables, such that repreated assignments to the same program variable is tracked as assignments to different variables. Once the program is in SSA form, we can extract a logical formaula by treating each assignent as an equality.

## Index

```@index
```
