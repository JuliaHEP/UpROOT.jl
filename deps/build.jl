# This file is a part of UpROOT.jl, licensed under the MIT License (MIT).

include("../src/testdata.jl")

isdir(testdatadir()) || mkdir(testdatadir())

for k in _testfile_keys
    download("https://github.com/scikit-hep/uproot/raw/3.5.1/tests/samples/$k.root", _testfilename(k))
end
