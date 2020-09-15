using GriddingMachine
using Test



# WARNING change this to false when merging into main branch
test_load_LUT = false;

# testing the module
@testset "GriddingMachine --- Monthly mean LAI" begin
    for FT in [Float32, Float64]
        GPP_TYPE = GPPVPMv20{FT}();
        LAI_TYPE = LAIMonthlyMean{FT}();
        VCM_TYPE = VcmaxOptimalCiCa{FT}();
        GPP_LUT  = GriddedDataset{FT}(data_type=GPP_TYPE);
        LAI_LUT  = load_LUT(LAI_TYPE);
        VCM_LUT  = load_LUT(VCM_TYPE);
        _gpp     = read_LUT(GPP_LUT, FT(30), FT(290), 2);
        _lai     = read_LUT(LAI_LUT, FT(30), FT(110), 8);
        _vcm     = read_LUT(VCM_LUT, FT(30), FT(110));
        @test typeof(_gpp) == FT;
        @test typeof(_lai) == FT;
        @test typeof(_vcm) == FT;

        # test the load_LUT function
        if test_load_LUT
            GPP_LUT1 = load_LUT(GPPMPIv006{FT}(), 2005, 0.5, "8D");
            GPP_LUT2 = load_LUT(GPPMPIv006{FT}(), 2005, 0.5, "1M");
            GPP_LUT3 = load_LUT(GPPVPMv20{FT}() , 2005, 0.2, "8D");
            LAI_LUT1 = load_LUT(LAI_TYPE);
            VCM_LUT1 = load_LUT(VCM_TYPE);
            _gpp1    = read_LUT(GPP_LUT1, FT(30), FT(290), 2);
            _gpp2    = read_LUT(GPP_LUT2, FT(30), FT(290), 2);
            _gpp3    = read_LUT(GPP_LUT3, FT(30), FT(290), 2);
            _lai1    = read_LUT(LAI_LUT1, FT(30), FT(110), 8);
            _vcm1    = read_LUT(VCM_LUT1, FT(30), FT(110));
            @test typeof(_gpp1) == FT;
            @test typeof(_gpp2) == FT;
            @test typeof(_gpp3) == FT;
            @test typeof(_lai1) == FT;
            @test typeof(_vcm1) == FT;
        end
    end
end
