# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

const AbstractBlob = AbstractVector{UInt8}

"""
    UpROOT.OpaqueObject{tp,B<:AbstractVector{UInt8}}

An opaque object of symbolic type `tp`. `tp` must be a `Symbol`. Use the
`data` field to access the byte representation.
"""
struct OpaqueObject{tp,B<:AbstractBlob}
    data::B
end


OpaqueObject{tp}(data::AbstractBlob) where {tp} = OpaqueObject{tp,typeof(data)}(data)



"""
    OpaqueObjectArray{tp,N,BA<:AbstractArray{<:AbstractBlob,N}}

An array of [`UpROOT.OpaqueObject`]s.
"""
struct OpaqueObjectArray{tp,N,BA<:AbstractArray{<:AbstractBlob,N}} <: AbstractArray{OpaqueObject{tp},N}
    data::BA
end


OpaqueObjectArray{tp}(data::AbstractArray{<:AbstractBlob,N}) where {tp,N} = OpaqueObjectArray{tp,N,typeof(data)}(data)


Base.size(A::OpaqueObjectArray) = size(A.data)

Base.IndexStyle(A::OpaqueObjectArray) = IndexStyle(A.data)

Base.@propagate_inbounds function Base.getindex(A::OpaqueObjectArray{tp}, idxs::Vararg{Integer,N}) where {tp,N}
    OpaqueObject{tp}(getindex(A.data, idxs...))
end

Base.@propagate_inbounds function Base.getindex(A::OpaqueObjectArray{tp}, idxs...) where {tp}
    OpaqueObjectArray{tp}(getindex(A.data, idxs...))
end
