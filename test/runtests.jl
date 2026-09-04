using GriddingMachine
using Test


# make sure the key features (data sharing) are working as expected
@testset "GriddingMachine" verbose = true begin
    include("collector.jl");
    include("indexer.jl");
    include("requestor.jl");
end;
