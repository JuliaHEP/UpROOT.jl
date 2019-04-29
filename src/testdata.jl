# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

"""
    UpROOT.testdatadir()::String

Path to some test data installed by UpROOT.jl for testing and experimentation
purposes.

Use `UpROOT.testfiles` to get `Dict` of all test files.
"""
testdatadir() = joinpath(dirname(@__DIR__), "deps", "testdata")


const _testfile_keys = [
    "leaflist",
    "HZZ",
]

_testfilename(k::AbstractString) = joinpath(testdatadir(), "$k.root")


const testfiles = Dict{String,String}()
