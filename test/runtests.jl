using GriddingMachine
using Test



# WARNING change this to false when merging into main branch
test_load_LUT = false;

# testing the module
@testset "GriddingMachine --- Monthly mean LAI" begin
    for FT in [Float32, Float64]
        GPP_DEF = MeanMonthlyLAI{FT}();
        LAI_DEF = MeanMonthlyLAI{FT}();
        _gpp    = read_LUT(GPP_DEF, FT(30), FT(290), 2);
        _lai    = read_LUT(LAI_DEF, FT(30), FT(110), 8);
        @test typeof(_gpp) == FT;
        @test typeof(_lai) == FT;

        # test the load_LUT function
        if test_load_LUT
            GPP_LUT = load_LUT(GPP_DEF, 2005, 0.2);
            LAI_LUT = load_LUT(LAI_DEF);
            _gpp    = read_LUT(GPP_LUT, FT(30), FT(290), 2);
            _lai    = read_LUT(LAI_LUT, FT(30), FT(110), 8);
            @test typeof(_gpp) == FT;
            @test typeof(_lai) == FT;
        end
    end
end
