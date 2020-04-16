using Images

"""
    dense(x, W, b)

Fully-connected or dense layer that given a
weight vector or matrix W, and a bias b, compute
the linear function y = Wx + b
"""
function dense(x, W, b)
    out = fill!(Array{PyObject,2}(undef, size(W,1), size(x,2)), 0)
    for i = 1:size(out,1), j = 1:size(W,2)
        out[i] += W[i,j] * x[j]
    end
    out = out .+ b
    if size(out,1) == 1
        return out[1]
    end
    return out
end

"""
    conv2D(x::Array{PyObject,2}, filter, stride_size = (2,2))

Apply a 2D Convolutional operation to a 2D matrix x, using the filter matrix
as the weight matrices.
"""
function conv2D(x::Array{PyObject,N}, filter, bias; stride_size::Tuple{Int,Int} = (2,2),
                padding_size = (1, 1)) where N
    x = padarray(x, Fill(0., padding_size))
    kernel_size = size(filter,1), size(filter,2), size(filter,3)
    width, height = size(x)
    [sum(x[i:(i-1)+kernel_size[1], j:(j-1)+kernel_size[2]] .* filter[:,:,c] .+ bias[c]) # apply filter to patch
              for i = 1:stride_size[1]:width-stride_size[1],                            # convole over image
                  j = 1:stride_size[2]:height-stride_size[2],
                  c = 1:kernel_size[3]]                                                 # using different filters
end

"""
    conv1D(x::Array{PyObject,1}, filter, stride_size = 2)

Apply a 1D convolution to x using the filter matrix.
"""
function conv1D(x::Array{PyObject,N}, filter, bias; stride_size::Int = 2,
                padding_size::Int = 1) where N
    x = padarray(x, Fill(0., (padding_size,)))
    kernel_size = size(filter,1), size(filter,2)
    width = size(x,1)
    [sum(x[i:(i-1)+kernel_size[1]] .* filter[:,:,c] .+ bias[c])    # apply filter to patch
              for i = 1:stride_size[1]:width-stride_size[1],       # convole
                  c = 1:kernel_size[2]]                            # using different filters
end

"""
    pool(x pool_op; poolsize=2, stride=2)

Generic pooling with the provided function
"""
function pool(x::Array{PyObject,2}, pool_op::Function; poolsize = 2, stride = 2)
    n, m, k = size(x);

    w, h = conv_out_size(n, m, poolsize, stride_size)
    out = Array{PyObject,1}(undef, w, h, k)

    count_w, count_h = 1,1

    for i = 1:stride_size[1]:w,
        j = 1:stride_size[2]:h,
        c = 1:k

        flattend_block = flatten(x[i:i+poolsize[1], j:j+poolsize[2], c])
        out[count_w,count_h] = pool_op(flattend_block)

        # TODO: improve the index of the output array
        count_w += 1
        if count_w > size(out,1)
            count_h += 1
            count_w = 1
        end

    end
    return out
end

"""
    maxpool(x; poolsize=2, stride=2)

Max pooling operation.
"""
function maxpool(x::Array{PyObject,2}; poolsize = 2, stride = 2)
    pool(x, max_fn, pool_op, stride)
end

"""
    avgpool(x; poolsize = 2, stride=2)

Average pooling operation
"""
function avgpool(x::Array{PyObject,2}; poolsize = 2, stride = 2)
    pool(x, avg_fn, poolsize, stride)
end

"""
    flatten(x)

Flatten a multidimensional matrix into a vector
"""
function flatten(x::Array{PyObject,2})
    out = Array{PyObject,1}(undef, prod([i for i in size(x)]))
    index = 1
    for i = 1:size(x,1), j = 1:size(x,2),
        out[i*j] = x[i,j]
        index += 1
    end
    return out
end

function flatten(x::Array{PyObject,3})
    out = Array{PyObject,1}(undef, prod([i for i in size(x)]))
    index = 1
    for k = 1:size(x,3), i = 1:size(x,1), j = 1:size(x,2)
        out[index] = x[i,j,k]
        index += 1
    end
    return out
end
