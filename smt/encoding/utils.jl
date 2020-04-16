# """
#     trace(m::Chain)
#
# Trace a simple Flux ML Chain Model
# """
# function trace(m::Chain, x)
#     z3 = Z3()
#
#     for l in m
#         @show l
#     end
# end


"""
W2=(W1-f)/s+1
H2=(H1-f)/s+1

w - width/height
k - kernel size
p - padding size
s - stride size
"""
function conv_out_size(w, h, k, s)
    out_size(x) = ((x - k)/s) + 1
    return out_size(w), out_size(h)
end
