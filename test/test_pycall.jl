# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

using Test

using PyCall

@testset "PyCall" begin
    @info "PyCall uses python command \"$(PyCall.python)\""
end
