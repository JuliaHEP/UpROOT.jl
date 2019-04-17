# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

import Test
Test.@testset "Package UpROOT" begin

include("test_pycall.jl")
include("test_testfiles.jl")

end # testset
