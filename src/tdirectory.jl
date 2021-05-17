# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

"""
    TDirectory

`UpROOT.TDirectory` is a wrapper around Python objects of type
`uproot.rootio.ROOTDirectory`.

`TDirectory` behaves similar to a Julia `Dict`, it supports the functions
`keys`, `length` and `getindex`.

Limitations: Write access is not implemented yet.

[`TFile`](@ref) is defined as an alias for TDirectory in UpROOT.jl.
"""
struct TDirectory
    pyobj::PyObject

    function TDirectory(x::PyObject)
        if !pybuiltin(:isinstance)(x, uproot.rootio.ROOTDirectory)
            throw(ArgumentError("Python object $x is not a ROOT TDirectory"))
        end
        new(x)
    end
end

export TDirectory

Base.keys(tdir::TDirectory) = pyobj(tdir).keys()

Base.length(tdir::TDirectory) = length(keys(tdir))

Base.getindex(tdir::TDirectory, objname::AbstractString) = py2jl(get(pyobj(tdir), PyObject, objname))



"""
    TFile = TDirectory

The uproot Python package doesn't use separate types for the ROOT classes
`TFile` and `TDirectoy` - so in UpROOT.jl, so in UpROOT.jl, `TFile` is just
defined as an alias for [`TDirectory`](@ref).

Constructors:

    * `TFile(filename::AbstractString)::TFile`

Use `TFile(filename)` to open files instead of `TDirectory(filename)` for
increased clarity in your code.
"""
const TFile = TDirectory

export TFile

TFile(filename::AbstractString) = TDirectory(uproot.open(filename))
