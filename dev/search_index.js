var documenterSearchIndex = {"docs":
[{"location":"ref/layers/#Layers","page":"Layers","title":"Layers","text":"","category":"section"},{"location":"ref/layers/","page":"Layers","title":"Layers","text":"CurrentModule = NeuralVerifier.Encoding","category":"page"},{"location":"ref/layers/#Simple-Layers","page":"Layers","title":"Simple Layers","text":"","category":"section"},{"location":"ref/layers/","page":"Layers","title":"Layers","text":"dense\nflatten","category":"page"},{"location":"ref/layers/#NeuralVerifier.Encoding.dense","page":"Layers","title":"NeuralVerifier.Encoding.dense","text":"dense(x, W, b)\n\nFully-connected or dense layer that given a weight vector or matrix W, and a bias b, compute the linear function y = Wx + b\n\n\n\n\n\n","category":"function"},{"location":"ref/layers/#NeuralVerifier.Encoding.flatten","page":"Layers","title":"NeuralVerifier.Encoding.flatten","text":"flatten(x)\n\nFlatten a multidimensional matrix into a vector\n\n\n\n\n\n","category":"function"},{"location":"ref/layers/#Convolutional-Layers","page":"Layers","title":"Convolutional Layers","text":"","category":"section"},{"location":"ref/layers/","page":"Layers","title":"Layers","text":"conv1D\nconv2D","category":"page"},{"location":"ref/layers/#NeuralVerifier.Encoding.conv1D","page":"Layers","title":"NeuralVerifier.Encoding.conv1D","text":"conv1D(x::Array{PyObject,1}, filter, stride_size = 2)\n\nApply a 1D convolution to x using the filter matrix.\n\n\n\n\n\n","category":"function"},{"location":"ref/layers/#NeuralVerifier.Encoding.conv2D","page":"Layers","title":"NeuralVerifier.Encoding.conv2D","text":"conv2D(x::Array{PyObject,2}, filter, stride_size = (2,2))\n\nApply a 2D Convolutional operation to a 2D matrix x, using the filter matrix as the weight matrices.\n\n\n\n\n\n","category":"function"},{"location":"ref/layers/#Pooling-Layers","page":"Layers","title":"Pooling Layers","text":"","category":"section"},{"location":"ref/layers/","page":"Layers","title":"Layers","text":"maxpool\navgpool","category":"page"},{"location":"ref/layers/#NeuralVerifier.Encoding.maxpool","page":"Layers","title":"NeuralVerifier.Encoding.maxpool","text":"maxpool(x; poolsize=2, stride=2)\n\nMax pooling operation.\n\n\n\n\n\n","category":"function"},{"location":"ref/layers/#NeuralVerifier.Encoding.avgpool","page":"Layers","title":"NeuralVerifier.Encoding.avgpool","text":"avgpool(x; poolsize = 2, stride=2)\n\nAverage pooling operation\n\n\n\n\n\n","category":"function"},{"location":"ref/activations/#Activations","page":"Activations","title":"Activations","text":"","category":"section"},{"location":"ref/activations/","page":"Activations","title":"Activations","text":"CurrentModule = NeuralVerifier.Encoding","category":"page"},{"location":"ref/activations/","page":"Activations","title":"Activations","text":"relu(x::PyObject)\nsigmoid(x::PyObject)","category":"page"},{"location":"ref/activations/#NeuralVerifier.Encoding.relu-Tuple{PyCall.PyObject}","page":"Activations","title":"NeuralVerifier.Encoding.relu","text":"relu(x)\n\nApply the ReLU activation function.\n\n\n\n\n\n","category":"method"},{"location":"ref/activations/#NeuralVerifier.Encoding.sigmoid-Tuple{PyCall.PyObject}","page":"Activations","title":"NeuralVerifier.Encoding.sigmoid","text":"sigmoid(x)\n\nApply a piecewise linear approximation to x.\n\n\n\n\n\n","category":"method"},{"location":"ref/activations/#Output-Activations","page":"Activations","title":"Output Activations","text":"","category":"section"},{"location":"ref/activations/","page":"Activations","title":"Activations","text":"sigmoid_bool(x::PyObject)\nsoftmax(x::PyObject)","category":"page"},{"location":"ref/activations/#NeuralVerifier.Encoding.sigmoid_bool-Tuple{PyCall.PyObject}","page":"Activations","title":"NeuralVerifier.Encoding.sigmoid_bool","text":"sigmoid_bool(x)\n\nApply the piecewise softmax function with 2 splits for binary classification.\n\n\n\n\n\n","category":"method"},{"location":"ref/activations/#NeuralVerifier.Encoding.softmax-Tuple{PyCall.PyObject}","page":"Activations","title":"NeuralVerifier.Encoding.softmax","text":"softmax(x::Array)\n\nApply the softmax operation. As we do not require the gradients, this is simply checking if each input is_argmax, if true, return the index label.\n\n\n\n\n\n","category":"method"},{"location":"#NeuralVerifier.jl-Documentation","page":"Home","title":"NeuralVerifier.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Verification is the process of building symbolic representations of reachable program states. In the context of verification of machine learning models, the symbolic representation of the model (nural network) may be a first-order formula that represents the decision process of said model.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Dynamic symbolic execution – using SMT solvers for checking path feasibility (activation of nodes)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Symbolic Software Model Checking – SMT solvers to bridge the gap from programs with large or unbouded state spaces into small finite state abstractions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Scalable static analysis – functional program verification to SMT solvers.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For loops and recursion, we use bounded recursion and bounded loops. This simply means that we limit the depth of the recursive calls by a fixed number. Likewise, bounded loops are traversed by a fixed number of iterations. In these cases there is a mapping from programs to logical formulas that summarise the input-output relations of the program. The mapping uses the single static assignment (SSA) representation of programs. The main idea is to unfold bounded loops and procedure calls then create a time-stamped version of the program variables, such that repreated assignments to the same program variable is tracked as assignments to different variables. Once the program is in SSA form, we can extract a logical formaula by treating each assignent as an equality.","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}