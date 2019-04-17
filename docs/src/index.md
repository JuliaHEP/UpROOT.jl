# UpROOT.jl

UpROOT.jl is a Julia wrapper around the Python [uproot](https://github.com/scikit-hep/uproot) package.

uproot makes it possible to read and write CERN ROOT files via pure Python (with certain limitations), without requiring a ROOT installation.


## Installation

UpROOT.jl requires the Python uproot package. If [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) is configured to use [Conda.jl](https://github.com/JuliaPy/Conda.jl) for package management (default on OS-X and Windows systems), uproot should be installed automatically when UpROOT.jl is loaded for the first time. Otherwise, please [install uproot manually](https://github.com/scikit-hep/uproot#installation) before using UpROOT.jl.


## Usage

UpROOT.jl exposes TFiles and TDirectories with a `Dict`-like API, TTrees and TBrances as exposed as out-of-core AbstractVectors that also support the Tables interface (with column-access). Opening a ROOT file and reading the contents is straightforward:

```julia
using UpROOT, Tables, TypedTables, ArraysOfArrays

file = TFile(UpROOT.testfiles["HZZ"])
println(keys(file))

tree = file["events"]
Tables.istable(tree) == true

tree[1] isa NamedTuple
tree[1:5] isa TypedTables.Table

tree.Jet_E isa AbstractVector
tree.Jet_E[1:5] isa VectorOfVectors
```

In addition to the standard Python/Julia type conversions provided by [PyCall.jl](https://github.com/JuliaPy/PyCall.jl), UpROOT.jl maps some special Python types used by uproot (e.g. types from the [awkward-array](https://github.com/scikit-hep/awkward-array) package) to Julia equivalents like [`VectorOfVectors`s](https://github.com/oschulz/ArraysOfArrays.jl) and [`Table`s](https://github.com/FugroRoames/TypedTables.jl).


## Limitations

Quite a bit of functionality of the Python uproot package (like writing files and caching of data) is not implemented/wrapped by UpROOT.jl yet. For now, please use the function [`UpROOT.pyobj`](@ref) to get the Python object wrapped by any UpROOT.jl type and access the unwrapped features directly via [PyCall.jl](https://github.com/JuliaPy/PyCall.jl). The python imports/modules uproot and awkward are available as `UpROOT.uproot` and `UpROOT.awkward`.
