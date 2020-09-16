using GriddingMachine
using Test



# WARNING change this to false when merging into main branch
test_load_LUT = false;

# testing the module
@testset "GriddingMachine --- Monthly mean LAI" begin
    # test the lat_ind and lon_ind
    @test typeof(lat_ind(  0.0)) == Int           ;
    @test typeof(lat_ind( 91.0)) == ErrorException;
    @test typeof(lon_ind(  0.0)) == Int           ;
    @test typeof(lon_ind(350.0)) == Int           ;
    @test typeof(lat_ind(361.0)) == ErrorException;

    # test the look up table functions
    for FT in [Float32, Float64]
        GPP_LUT = GriddedDataset{FT}(data_type=GPPVPMv20{FT}());
        CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
        LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
        LNC_LUT = load_LUT(LeafNitrogen{FT}());
        LPC_LUT = load_LUT(LeafPhosphorus{FT}());
        SLA_LUT = load_LUT(LeafSLA{FT}());
        VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
        for _val in [ read_LUT(CHT_LUT, FT(30), FT(110)),
                      read_LUT(GPP_LUT, FT(30), FT(110), 2),
                      read_LUT(LAI_LUT, FT(30), FT(110), 8),
                      read_LUT(LNC_LUT, FT(30), FT(110)),
                      read_LUT(LPC_LUT, FT(30), FT(110)),
                      read_LUT(SLA_LUT, FT(30), FT(110)),
                      read_LUT(VCM_LUT, FT(30), FT(110))]
            @test typeof(_val) == FT;
        end

        # test the load_LUT function
        if test_load_LUT
            GPP_LUT1 = load_LUT(GPPMPIv006{FT}(), 2005, 0.5, "8D");
            GPP_LUT2 = load_LUT(GPPMPIv006{FT}(), 2005, 0.5, "1M");
            GPP_LUT3 = load_LUT(GPPVPMv20{FT}() , 2005, 0.2, "8D");
            for _val in [ read_LUT(GPP_LUT1, FT(30), FT(110), 2),
                          read_LUT(GPP_LUT2, FT(30), FT(110), 2),
                          read_LUT(GPP_LUT3, FT(30), FT(110), 2)]
                @test typeof(_val) == FT;
            end
        end
    end
end
