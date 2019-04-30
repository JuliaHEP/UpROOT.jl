# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

function pyjaggedarray2jl(x::PyObject)
    from = convert(Vector{Int}, x.starts)::Vector{Int}
    until = convert(Vector{Int}, x.stops)::Vector{Int}

    data = x.content
    T = eltype(data)

    @assert from[2:end] == until[1:end-1]
    n = size(from, 1)

    elem_ptr = Vector{Int}(undef, n + 1)
    elem_ptr[1:end-1] = from
    elem_ptr[end] = until[end]
    elem_ptr .+= 1

    kernel_size = Vector{Tuple{}}(undef, n)

    VectorOfArrays(data, elem_ptr, kernel_size, ArraysOfArrays.no_consistency_checks)
end


function awkwardobjectarray2jl(x::PyObject)
    tp = Symbol(x.generator.cls.__name__)
    data = pyjaggedarray2jl(x._content)

    OpaqueObjectArray{tp}(data)
end


py2jl(x::Any) = x

function py2jl(x::PyObject)
    if pybuiltin(:isinstance)(x, awkward.JaggedArray)
        pyjaggedarray2jl(x)
    elseif pybuiltin(:isinstance)(x, awkward.array.table.Table)
        Table(_dict2nt(x._contents))
    elseif pybuiltin(:isinstance)(x, awkward.array.objects.ObjectArray)
        awkwardobjectarray2jl(x)
    elseif pybuiltin(:isinstance)(x, uproot.rootio.ROOTDirectory)
        TDirectory(x)
    elseif pybuiltin(:isinstance)(x, uproot.tree.TTreeMethods)
        TTree(x)
    elseif pybuiltin(:isinstance)(x, uproot.tree.TBranchMethods)
        TBranch(x)
    else
        pytypename = pybuiltin(:type)(x).__name__
        @warn "Conversion of python type $pytypename to a Julia type not supported"
        x
    end
end


_dict2nt(d::Dict) = NamedTuple{Tuple(Symbol.(keys(d)))}(py2jl.(values(d)))
