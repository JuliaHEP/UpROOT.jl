# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

using UpROOT
using Test

using ArraysOfArrays
using TypedTables
using StatsBase

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

        @test tree[1:5, (:Jet_Px, :Jet_Py, :Jet_Pz)] isa Table{<:NamedTuple{(:Jet_Px, :Jet_Py, :Jet_Pz)}}
        @test tree[:, [:Jet_Px, :Jet_Py, :Jet_Pz]] isa Table{<:NamedTuple{(:Jet_Px, :Jet_Py, :Jet_Pz)}}
        @test tree[[2, 4, 7, 11], ["Jet_Px", "Jet_Py", "Jet_Pz"]] isa Table{<:NamedTuple{(:Jet_Px, :Jet_Py, :Jet_Pz)}}
    end


    @testset "histograms" begin
        file = TFile(UpROOT.testfiles["hepdata-example"])
        @test "hpx;1" in keys(file)
        @test "hpxpy;1" in keys(file)
        hpx = file["hpx;1"]
        hpxpy = file["hpxpy;1"]

        @test hpx isa Histogram{<:Real, 1}
        @test hpxpy isa Histogram{<:Real, 2}
    end
end
