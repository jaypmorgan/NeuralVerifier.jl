"""
    sigmoid(x)

Apply a piecewise linear approximation to x.
"""
function sigmoid(x::PyObject)
    If(x < 0,  # TODO: larger piecewise approximations
        If(x < -2, 0.0, 0.4),
        If(x >  2, 0.6, 1.0)
    )
end

"""
    sigmoid(x, binary)

Apply the piecewise softmax function with 2 splits
for binary classification.
"""
function sigmoid(x::PyObject; binary)
    If(x < 0, 0.0, 1.0)
end

"""
    sigmoid(x::Array)

Apply the sigmoid function elementwise.
"""
function sigmoid(x::Array{PyObject,N} where N)
    out = Array{PyObject}(undef, size(x)...)
    for index in CartesianIndices(out)
        out[index] = sigmoid(x[index])
    end
    return out
end

"""
    relu(x)

Apply the ReLU activation function.
"""
function relu(x::PyObject)
    If(x > 0, x, 0)
end

"""
    relu(x::Array)

Apply the relu function elementwise.
"""
function relu(x::Array{PyObject,N} where N)
    out = Array{PyObject}(undef, size(x)...)
    for index in CartesianIndices(out)
        out[index] = relu(x[index])
    end
    return out
end

"""
    is_argmax(x, S)

Recurvsive function for finding if x is larger
than the rest of the set.
"""
function is_argmax(x, S, l = 1)
    if x == l
        return is_argmax(x, S, l + 1)
    elseif l <= size(S,1)
        return If(S[x] > S[l], is_argmax(x, S, l + 1), false)
    else
        return true
    end
end

"""
    softmax(x::Array)

Apply the softmax operation. As we do not require
the gradients, this is simply checking if each input
is_argmax, if true, return the index label.
"""
function softmax(x; l = 1)
    if l == size(x,1)
        return l
    else
        return If(is_argmax(l, x, 1) == false, softmax(x; l = l + 1), l)
    end
end

"""
    is_max(x)

Recurivse solution to find a max of a vector.
"""
function is_max(x, index; j = 1)
    if index == j
        return is_max(x, index, j=j+1)
    elseif j <= size(x,1)
        return If(x[index] > x[j], is_max(x, index; j=j+1), false)
    else
        return true
    end
end


"""
    max_fn(x)

Find the maximum number from a vector.
"""
function max_fn(x; l = 1)
    if l == size(x,1)
        return x[l]
    else
        return If(is_max(x, l; j = 1) == false, max_fn(x; l = l + 1), x[l])
    end
end

"""
    avg_fn(x)

Find the average of all numbers from a vector.
"""
function avg_fn(x)
    sum(x)/size(x,1)
end
