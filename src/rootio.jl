# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

const kByteCountMask = UInt32(0x40000000)
const kByteCountMask_UInt16 = UInt16(kByteCountMask >> 16)


struct ROOTIOBuffer{T}
    buffer::Base.GenericIOBuffer{T}
end

ROOTIOBuffer(data::AbstractVector{UInt8}) = ROOTIOBuffer(IOBuffer(data))


Base.eof(io::ROOTIOBuffer) = eof(io.buffer)


function Base.read(io::ROOTIOBuffer, ::Type{String})
    short_len = read(io.buffer, UInt8)
    len = (short_len < 0xff) ? UInt32(short_len) : read(io.buffer, UInt32)
    String(read(io.buffer, len))
end


function Base.read(io::ROOTIOBuffer, ::Type{T}) where {T<:Real}
    x::T = read(io.buffer, T)
    if sizeof(T) > 1
        x = ntoh(x)
    end
    x
end


function Base.read(io::ROOTIOBuffer, ::Type{Vector{T}}) where {T<:Real}
    len = read(io, UInt32)
    A = Vector{T}(undef, len)
    read!(io.buffer, A)
    if sizeof(T) > 1
        A .= ntoh.(A)
    end
    A
end



struct ROOTClassHeader
    classname::String
end

function Base.read(io::ROOTIOBuffer, ::Type{ROOTClassHeader})
    classname = read(io, String)
    padding = read(io, UInt8)
    ROOTClassHeader(classname)
end



struct ROOTClassVersion
    nbytes::UInt32
    version::Int16
end

function Base.read(io::ROOTIOBuffer, ::Type{ROOTClassVersion})
    a = read(io, UInt16)

    if a & kByteCountMask_UInt16 > 0
        # byte count available
        b = read(io, UInt32)
        cnt = (UInt32(a & ~kByteCountMask_UInt16) << 16 | b >> 16)
        version = b % Int16
        bytecount = cnt - sizeof(version)
        ROOTClassVersion(bytecount, version)
    else
        ROOTClassVersion(0, signed(a))
    end
end



struct TObjectContent
    fUniqueID::UInt32
    fBits::UInt32
end

function Base.read(io::ROOTIOBuffer, ::Type{TObjectContent})
    ver = read(io, ROOTClassVersion)
    @assert ver.nbytes == 0
    @assert ver.version == 1
    fUniqueID = read(io, UInt32)
    fBits = read(io, UInt32)
    TObjectContent(fUniqueID, fBits)
end



struct TNamedContent{S<:AbstractString}
    tobject::TObjectContent
    fName::S
    fTitle::S
end

function Base.read(io::ROOTIOBuffer, ::Type{TNamedContent})
    ver = read(io, ROOTClassVersion)
    @assert ver.version == 1
    tobject = read(io, TObjectContent)
    fName = read(io, String)
    fTitle = read(io, String)
    TNamedContent(tobject, fName, fTitle)
end



struct TClonesArrayHeader{S<:AbstractString}
    tobject::TObjectContent
    fName::S
    fClass::S
    nobjects::Int
    fLowerBound::Int
end

function Base.read(io::ROOTIOBuffer, ::Type{TClonesArrayHeader})
    ver = read(io, ROOTClassVersion)
    @assert ver.version == 4
    tobject = read(io, TObjectContent)
    fName = read(io, String)
    fClass = read(io, String)
    nobjects = read(io, Int32)
    fLowerBound = read(io, Int32)

    # assuming CanBypassStreamer() is false:
    nch = read(io, Int8)
    TClonesArrayHeader(tobject, fName, fClass, Int(nobjects), Int(fLowerBound))
end
