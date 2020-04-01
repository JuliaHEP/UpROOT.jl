# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

"""
    TTree <: AbstractVector{Any}

`UpROOT.TTree` is a wrapper around Python objects with mix-in
`uproot.tree.TTreeMethods`. It behaves like a Julia `AbstractVector` and
`Tables.Table` (with column access).

`TTree` is an on-disk data structure, iteration over single elements is *very*
inefficient.

Limitations: Write access is not implemented yet.
"""
struct TTree <: AbstractVector{NamedTuple}
    pyobj::PyObject

    function TTree(x::PyObject)
        if !pybuiltin(:isinstance)(x, uproot.tree.TTreeMethods)
            throw(ArgumentError("Python object $x is not a ROOT TTree"))
        end
        new(x)
    end
end

export TTree


pyobj(tree::TTree) = Base.getfield(tree, :pyobj)


Base.propertynames(tree::TTree) = Symbol.(pyobj(tree).keys())

Base.getproperty(tree::TTree, name::Symbol) = TBranch(get(pyobj(tree), String(name)))

Base.size(tree::TTree) = (pyobj(tree).numentries,)

Base.IndexStyle(tree::TTree) = IndexLinear()

function Base.getindex(tree::TTree, idxs::AbstractUnitRange)
    @boundscheck checkbounds(tree, idxs)
    cols = pyobj(tree).arrays(entrystart = first(idxs) - 1, entrystop = last(idxs))

    colnames = Tuple(Symbol.(keys(cols)))
    colvals_py = values(cols)
    colvals_jl = _branch_content.(py2jl.(colvals_py))

    Table(NamedTuple{colnames}(colvals_jl))
end

Base.getindex(tree::TTree, i::Integer) = first(tree[i:i])

Base.getindex(tree::TTree, ::Colon) = getindex(tree, eachindex(tree))


Tables.istable(::Type{TTree}) = true

Tables.columnaccess(::Type{TTree}) = true

Tables.columns(tree::TTree) = Dict(name => getproperty(tree, name) for name in Tables.columnnames(tree))

function Tables.schema(tree::TTree)
    props = Base.propertynames(tree)
    Tables.Schema(props, map(_ -> Any, props))
end


"""
    TBranch <: AbstractVector{Any}

`UpROOT.TBranch` is a wrapper around Python objects with mix-in
`uproot.tree.TBranchMethods`. It behaves like a Julia `AbstractVector`. Ff
the branch has children, it also behaves like a `Tables.Table` (with column
access).

`TBranch` is an on-disk data structure, iteration over single elements is *very*
inefficient.

Limitations: Write access is not implemented yet.
"""
struct TBranch <: AbstractVector{Any}
    pyobj::PyObject

    function TBranch(x::PyObject)
        if !pybuiltin(:isinstance)(x, uproot.tree.TBranchMethods)
            throw(ArgumentError("Python object $x is not a ROOT TBranch"))
        end
        new(x)
    end
end

export TBranch


Base.propertynames(branch::TBranch) = Symbol.(pyobj(branch).keys())

Base.getproperty(branch::TBranch, name::Symbol) = TBranch(get(pyobj(branch), String(name)))

Base.size(branch::TBranch) = (pyobj(branch).numentries,)

Base.IndexStyle(branch::TBranch) = IndexLinear()

function Base.getindex(branch::TBranch, idxs::AbstractUnitRange)
    @boundscheck checkbounds(branch, idxs)
    content = pyobj(branch).array(entrystart = first(idxs) - 1, entrystop = last(idxs))
    _branch_content(py2jl(content))
end

Base.getindex(branch::TBranch, i::Integer) = first(branch[i:i])

Base.getindex(branch::TBranch, ::Colon) = getindex(branch, eachindex(branch))


Tables.istable(::Type{TBranch}) = true

Tables.columnaccess(::Type{TBranch}) = true

Tables.columns(branch::TBranch) = branch # Dict(broadcast(item -> Symbol(item[1]) => TBranch(item[2]), pyobj(branch).items()))

function Tables.schema(branch::TBranch)
    props = Base.propertynames(branch)
    Tables.Schema(props, map(_ -> Any, props))
end

function read_ttree(tree::PyObject, branchnames::Array{<:AbstractString})
    tree_data = tree.arrays(branchnames)

    df = DataFrame()
    for bn in branchnames
        df[Symbol(bn)] = py2jl(tree_data[bn])
    end

    df
end


function read_ttree(filename::AbstractString, treename::AbstractString)
    file = uproot.open(filename)
    tree = get(file, treename)
    branchnames = tree.keys()
    read_ttree(tree, branchnames)
end


function read_ttree(filename::AbstractString, treename::AbstractString, branchnames::Array{<:AbstractString})
    file = uproot.open(filename)
    tree = get(file, treename)
    read_ttree(tree, branchnames)
end


function read_ttree(filename::AbstractString, treename::AbstractString, branchnames::Array{Symbol})
    read_ttree(filename, treename, String.(branchnames))
end


_branch_content(A::AbstractVector) = A

# uproot returns some branches containing fix-size n-dim array data as
# (n+1)-dim arrays. Permutation of dimensions in _branch_content changes
# memory layout and preserves order of indices. So a branch containing
# static C arrays of size [2][3] becomes a vector of arrays of size (2, 3) in
# Julia.
function _branch_content(A::AbstractArray)
    dimidxs = ntuple(i -> i, Val(length(size(A))))
    branchdim = first(dimidxs)
    innerdims = Base.tail(dimidxs)
    VectorOfSimilarArrays(permutedims(A, (innerdims..., branchdim)))
end
