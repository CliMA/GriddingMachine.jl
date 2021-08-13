using GriddingMachine.Collections
using Test


# test query_collection function
@testset "GriddingMachine : Collections" begin
    query_collection(VcmaxCollection(), "2X_1Y_V1"); @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.total_memory() / 2^30) > 30
        query_collection(VcmaxCollection(), "2X_1Y_V1"); @test true;
        query_collection(VcmaxCollection(), "2X_1Y_V2"); @test true;
    end
end
