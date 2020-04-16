using Base.Threads;
using ProgressMeter;

"""
    has_adversarial(f, x, ϵ; timeout)

Check whether an adversarial exists with the open ball region of x
with the radius ϵ for the classifier f.
"""
function has_adversarial(f::Function, x::Array{T,1}, ϵ; timeout::Int,
                         build_fn::Function) where T
    m::Solver = Solver()
    n_dims::Int = size(x,1)
    vars = [Z3Float("x$i") for i = 1:n_dims]

    # create an open ball region around x
    for i = 1:n_dims
        add!(m, And(vars[i] > x[i] .- ϵ, vars[i] < x[i] .+ ϵ))
    end

    y = build_fn(vars)
    add!(m, y != f(x))
    m.solver.set("timeout", timeout)
    check(m)

    return m.is_sat
end

"""
    adversarials(f, x, ϵ; timeout = 10_000)

Find the satisfiability of adversarials existing within open ball regions
of datapoints x with the radii of ϵ.
"""
function adversarials(f::Function, x::Array{T,N}, ϵ::Array{T,1};
                      timeout::Int = 10_000, build_fn::Function) where {T,N}
    n_samples::Int = size(x,1)
    n_dims::Int = size(x,2)
    adversarial_exists::Array{String,1} = Array{String,1}(undef, n_samples)

    @showprogress for i = 1:n_samples
        adversarial_exists[i] = has_adversarial(f, x[i,:], ϵ[i];
            timeout = timeout, build_fn = build_fn)
    end

    return adversarial_exists
end

"""
    stable_region(f, x, ϵ; step_size = 0.01, timeout = 10_000)

Find the actual stable region size for the classifier f.
"""
function stable_region(::Type{SMT.Solver}, f, x, ϵ; step_size = 0.01, timeout = 10_000,
                       build_fn::Function)
    region_sizes::Array{Float64,1} = zero(ϵ)
    adv_exists::Array{Float64,1} = zero(ϵ)

    for step = minimum(ϵ):step_size:maximum(ϵ)
        # get the samples for which the estimated is larger than step
        samples_to_check = findall((ϵ .> step) .& (adv_exists .!= 1))
        samples, radii = x[samples_to_check,:], ϵ[samples_to_check]

        # find satisfiability of adversarial in this region.
        is_unsat = findall(x -> x != "unsat", adversarials(f, samples, radii;
            timeout = timeout, build_fn = build_fn))
        region_sizes[is_unsat] .= step
        adv_exists[.!in_unsat] .= 1

        if all(adv_exists .== 1)
            break  # all max regions have been found
        end
    end
    return region_sizes
end

"""
    stable_region(::Optimize, f, x, ϵ; timeout, build_fn)

Search for the closest adversarials in the dataset x using the
network f, and the encoding: build_fn. In this function ϵ specifies the
radius for the open-ball region around each xᵢ ∈ x.
"""
function stable_region(::Type{SMT.Optimize}, f, x::AbstractArray{T,N}, ϵ::AbstractArray{T,1};
                       timeout::Int = 10_000, build_fn::Function) where {T,N}
    region_sizes::Array{T,1} = zero(ϵ)
    adv_examples::Array{T,N} = zero(x)
    dim, n = size(x)

    for (idx, xi) in enumerate(eachrow(x))
        m = Optimize()
        e = z3.Real("e")
        add!(m, (e > 0) ∧ (e < ϵ[idx]))

        vars = [z3.Real("x$i") for i = 1:n]
        for (j, var) in enumerate(vars)
            add!(m, (var > (xi[j] - e)) ∧ (var < (xi[j] + e)))
        end

        minimize!(m, e)
        y = build_fn(vars)
        add!(m, y != f(xi))
        m.solver.set("timeout", timeout)
        @show idx, check(m)

        if m.is_sat == "sat"
            region_sizes[idx] = variable(m, e)
            adv_examples[idx,:] = [variable(m, var) for var in vars]
        else
            region_sizes[idx] = ϵ[idx]
        end
    end

    return region_sizes, adv_examples
end

"""
    stable_region(::Optimize, f, x, ϵ; timeout, build_fn)

Search for the closest adversarials in the dataset x using the
network f, and the encoding: build_fn. Here ϵ specifies the bounding box
or hypercube around each data point in x for the search of
adversarial examples.
"""
function stable_region(::Type{SMT.Optimize}, f, x::AbstractArray{T,N}, ϵ::AbstractArray{T,3};
                       timeout::Int = 10_000, build_fn::Function) where {T,N}
    region_sizes::Array{T,3} = zero(ϵ)
    adv_examples::Array{T,N} = zero(x)
    dim, sample = size(x)

    for (idx, xi) in enumerate(eachcol(x))
        m = Optimize()

        vars = [z3.Real("x$i") for i = 1:dim]
        e    = [z3.Real("e$(i*j)") for i = 1:dim, j = 1:2]

        for (j, var) in enumerate(vars)
            add!(m, (e[j,1] > 0) ∧ (e[j,1] < ϵ[j,2,idx]))
            add!(m, (e[j,2] > 0) ∧ (e[j,2] < ϵ[j,1,idx]))
            add!(m, (var >= (xi[j] - e[j,1])) ∧ (var <= (xi[j] + e[j,2])))
        end

        minimize!(m, sum(e))
        y = build_fn(vars)
        add!(m, y != f(xi))
        m.solver.set("timeout", timeout)
        @show idx, check(m)

        if m.is_sat == "sat"
            region_sizes[:,:,idx] = [variable(m, ei) for ei in e]
            adv_examples[:,idx] = [variable(m, var) for var in vars]
        else
            region_sizes[:,:,idx] = ϵ[:,:,idx]
        end
    end

    return region_sizes, adv_examples
end
