using GriddingMachine
using Test




# testing the module
@testset "GriddingMachine --- Monthly mean LAI" begin
    for FT in [Float32, Float64]
        # TODO Need to use artifacts later
        LAI_map = mean_LAI_map(FT);
        _lai    = read_LAI(LAI_map, FT(30), FT(110), 8);
        @test typeof(_lai) == FT;
    end
end
