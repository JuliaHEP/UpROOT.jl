# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

using Test
using UpROOT
import Documenter

Documenter.DocMeta.setdocmeta!(
    UpROOT,
    :DocTestSetup,
    :(using UpROOT);
    recursive=true,
)
Documenter.doctest(UpROOT)
