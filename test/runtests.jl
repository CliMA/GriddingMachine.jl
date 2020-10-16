using GriddingMachine
using Test



# WARNING change this to false when merging into main branch
FT = Float32;
test_huge_LUT = false;




# test utility functions
@testset "GriddingMachine --- Lat/Lon indicies" begin
    println("");
    # test the lat_ind and lon_ind
    @test typeof(lat_ind(  0.0)) == Int           ;
    @test typeof(lat_ind( 91.0)) == ErrorException;
    @test typeof(lon_ind(  0.0)) == Int           ;
    @test typeof(lon_ind(350.0)) == Int           ;
    @test typeof(lat_ind(361.0)) == ErrorException;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Load and Read datasets" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());                @test true;
    CLI_PFT = load_LUT(ClumpingIndexPFT{FT}());                @test true;
    CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y"); @test true;
    MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "1X", "8D");    @test true;
    VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "1X", "8D");    @test true;
    LAI_LUT = load_LUT(LAIMonthlyMean{FT}());                  @test true;
    CHL_LUT = load_LUT(LeafChlorophyll{FT}());                 @test true;
    LNC_LUT = load_LUT(LeafNitrogen{FT}());                    @test true;
    LPC_LUT = load_LUT(LeafPhosphorus{FT}());                  @test true;
    NPP_LUT = load_LUT(NPPModis{FT}());                        @test true;
    SLA_LUT = load_LUT(LeafSLA{FT}());                         @test true;
    VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());                @test true;

    read_LUT(CLI_PFT, FT(30), FT(115), 2); @test true;
    read_LUT(LAI_LUT, FT(30), FT(115), 2); @test true;
    read_LUT(SLA_LUT, FT(30), FT(115)   ); @test true;

    if test_huge_LUT
        CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "240X", "1Y"); @test true;
        MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "1M");     @test true;
        VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "5X", "8D");     @test true;
    end
end




# test clumping factor artifacts
@testset "GriddingMachine --- Mask dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    mask_LUT!(CHT_LUT, [0,60]); @test true;
    mask_LUT!(CHT_LUT, -9999 ); @test true;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Regrid and Save dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    mask_LUT!(CHT_LUT, [0,10]);
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=true ); @test true;
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=false); @test true;
    save_LUT(REG_LUT, "test.nc"); @test true;
    rm("test.nc");
end
