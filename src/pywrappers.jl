# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

"""
    UpROOT.pyobj(x)::PyObject

Get the python object wrapped by Julia object `x`. `x` may be a
[`TFile`](@ref)/[`TDirectory`](@ref), [`TDirectory`](@ref) or
[`TBranch`](@ref).
"""
pyobj(x) = Base.getfield(x, :pyobj)
