# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

__precompile__(true)

module UpROOT

using ArraysOfArrays
using PyCall
using Tables
using TypedTables

awkward = PyNULL()
uproot = PyNULL()

include("testdata.jl")
include("pywrappers.jl")
include("rootio.jl")
include("opaque.jl")
include("pyjlconv.jl")
include("tdirectory.jl")
include("ttree.jl")

function __init__()
    copy!(awkward, pyimport_conda("awkward", "awkward", "conda-forge"))
    copy!(uproot, pyimport_conda("uproot", "uproot", "conda-forge"))

    for k in _testfile_keys
        testfiles[k] = _testfilename(k)
    end
end

end # module
