module NeuralVerifier

using PyCall
using Conda


z3 = try
    pyimport_conda("z3", "z3")
catch
    throw("Error importing Z3, please install `z3-solver`. Example: `pip install z3-solver`")
end

z3.set_param("parallel.enable", true)

export
    z3, # direct access to the pyz3 interface
    Solver,
    Optimize,
    add!,
    model,
    And,
    Or,
    If,
    Not,
    minimize!,
    maximize!,
    check,
    Z3Float,
    Z3Int,
    variable,
    ∧,
    ∨,
    ⟹,
    ¬,
    weight,
    bias

mutable struct Solver
    solver
    model
    is_sat
end

mutable struct Optimize
    solver
    model
    is_sat
end

const Z3 = Union{Solver, Optimize}

# empty constructors
Solver() = Solver(z3.Solver(), nothing, nothing)
Optimize() = Optimize(z3.Optimize(), nothing, nothing)

# wrappers for common functions
add!(m::T, expr) where T <: Z3 = m.solver.add(expr)
model(m::T) where T <: Z3 = m.model
And(expr1::PyObject, expr2::PyObject) = z3.And(expr1, expr2)
Or(expr1::PyObject, expr2::PyObject) = z3.Or(expr1, expr2)
If(expr1::PyObject, res1, res2) = z3.If(expr1, res1, res2)
Not(expr::PyObject) = z3.Not(expr)

# optimize specific functions
minimize!(m::Optimize, expr::PyObject) = m.solver.minimize(expr)
maximize!(m::Optimize, expr::PyObject) = m.solver.maximize(expr)

# numeric types and variables
Z3Float(s::String) = z3.FP(s, z3.FPSort(8, 24))
Z3Int(s::String) = z3.Int(s)
variable(m::T, var::PyObject) where T <: Z3 = begin
    v = m.model.__getitem__(var).as_string()
    object_type = var.sort_kind()

    if object_type == 2 # Int
        variable_string_to_int(v)
    elseif object_type == 3
        variable_string_to_real(v)
    elseif object_type == 9
        variable_string_to_float(v)
    else
        throw("Type: [$(var.sort()), $(var.sort_kind())] not yet implemented")
    end
end

var_real_regex = r"(\d+)\/?(\d+)?"
function variable_string_to_real(v::String)::Float64
    matches = match(var_real_regex, v)
    if matches[2] != nothing
        return parse(BigInt, matches[1]) / parse(BigInt, matches[2])
    else
        return parse(BigInt, matches[1])
    end
end

function variable_string_to_int(v::String)
    throw("Not yet implemented")
end

var_regex = r"FPVal\((\d+.\d+)\s(-?\d+)"
function variable_string_to_float(v::String)
    matches = match(var_regex, v)
    return parse(Float64, matches[1]) * (2^parse(Float64, matches[2]))
end

function check(m::T) where T <: Z3
    result = m.solver.check()
    if result == z3.sat
        m.is_sat = "sat"
        m.model = m.solver.model()
    elseif result == z3.unsat
        m.is_sat = "unsat"
    else
        m.is_sat = "unknown"
    end
    return m.is_sat
end

# nice to have rules
∧(x::T, y::T) where {T <: PyObject} = z3.And(x, y)
∨(x::T, y::T) where {T <: PyObject} = z3.Or(x, y)
⟹(x::T, y::T) where {T <: PyObject} = z3.Implies(x, y)
¬(x::T) where {T <: PyObject} = z3.Not(x)

weight(s::String, n::Int, m::Int) = [Z3Float("$s$(i*j)") for i = 1:n, j = 1:m]
bias(s::String, n::Int) = [Z3Float("$s$i"); for i = 1:n]

include("encoding.jl")
end
