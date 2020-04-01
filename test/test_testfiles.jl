# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

using UpROOT
using Test

using ArraysOfArrays
using TypedTables

@testset "testfiles" begin
    @testset "leaflist" begin
        file = TFile(UpROOT.testfiles["leaflist"])
        @test "tree;1" in keys(file)
        tree = file["tree"]
 
        @test tree[1] isa NamedTuple
        @test tree[1].leaflist isa NamedTuple
        @test tree[1:5] isa Table
        @test tree[1:5].leaflist isa Table
        @test tree[:] isa Table
        @test tree[:].leaflist isa Table
 
        @test tree.leaflist[1] isa NamedTuple
        @test tree.leaflist[1:5] isa Table
        @test tree.leaflist[:] isa Table

        @test tree[1].leaflist == tree.leaflist[1]
    end


    @testset "HZZ" begin
        file = TFile(UpROOT.testfiles["HZZ"])
        @test "events;1" in keys(file)
        tree = file["events"]
 
        @test tree[1] isa NamedTuple
        @test tree[1:5] isa Table
        @test tree[:] isa Table
 
        @test tree.Jet_E[1] isa AbstractVector
        @test tree.Jet_E[1:5] isa VectorOfVectors
        @test tree.Jet_E[:] isa VectorOfVectors

        @test copy(tree.Jet_E) == tree.Jet_E[:]
        @test Array(tree.Jet_E) == tree.Jet_E[:]
        @test convert(Array, tree.Jet_E) == tree.Jet_E[:]

        @test Table(tree) == tree[:]
    end
end
