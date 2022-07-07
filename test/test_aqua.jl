# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

import Test
import Aqua
import UpROOT

Test.@testset "Aqua tests" begin
    Aqua.test_all(UpROOT)
end # testset
