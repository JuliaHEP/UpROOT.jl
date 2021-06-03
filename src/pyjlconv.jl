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

    content = x.content

    data = if content isa PyObject
        # Content used to be an awkward.JaggedArray, at least in in older uproot/awkward-array versions
        py2jl(x.content)
    elseif content isa Array{PyObject,2}
        # Content now seems to be an ndarray with object bytes in [:,1] and something else (what?) in [:,2]
        Array.(PyArray.(x.content[:,1]))
    else
        throw(ArgumentError("Unexpected content type $(typeof(content)) of awkward.array.objects.ObjectArray"))
    end

    OpaqueObjectArray{tp}(data)
end

function _conv_hist_edge(edge::AbstractVector{<:Real})
    steps = diff(edge)
    step_size = mean(steps)
    if all(isapprox(first(steps)), step_size)
        minimum(edge):step_size:maximum(edge)
    else
        edge
    end
end

_hist_edges(edges::AbstractVector{<:Real}) = _conv_hist_edge(edges)
_hist_edges(edges::NTuple{N,AbstractVector{<:Real}}) where N = map(_conv_hist_edge, edges)

function roothist2jl(x::PyObject)
    edges = _hist_edges(x.edges)
    weights = x.values
    Histogram(edges, weights, :left)
end


py2jl(x::Any) = x

function py2jl(x::PyObject)
    if pybuiltin(:isinstance)(x, numpy.ndarray)
        _numpy2jl_impl(x.tolist(), x.dtype.names)
    elseif pybuiltin(:isinstance)(x, awkward.JaggedArray)
        pyjaggedarray2jl(x)
    elseif pybuiltin(:isinstance)(x, awkward.array.table.Table)
        Table(_py2jl_dict2nt(x._contents))
    elseif pybuiltin(:isinstance)(x, awkward.array.objects.ObjectArray)
        awkwardobjectarray2jl(x)
    elseif pybuiltin(:isinstance)(x, uproot.rootio.ROOTDirectory)
        TDirectory(x)
    elseif pybuiltin(:isinstance)(x, uproot.tree.TTreeMethods)
        TTree(x)
    elseif hasproperty(x, :bins)
        roothist2jl(x)
    else
        y = convert(PyAny, x)
        if y isa PyObject
            pytypename = pybuiltin(:type)(x).__name__
            @warn "Conversion of python type $pytypename to a Julia type not supported"
            x
        end
    end
end

_py2jl_dict2nt(d::Dict) = NamedTuple{Tuple(Symbol.(keys(d)))}(py2jl.(values(d)))


function _numpy2jl_impl(data::AbstractArray{<:Tuple}, fieldnames::NTuple{N,String}) where N
    fieldsyms = Symbol.(fieldnames)
    ntarray = NamedTuple{fieldsyms}.(data)
    Table(ntarray)
end
