using GriddingMachine
using PkgUtility
using Test

FT = Float32;




# test utility functions
@testset "GriddingMachine --- Lat/Lon indicies" begin
    # test the lat_ind and lon_ind
    @test typeof(GriddingMachine.lat_ind(  0.0)) == Int           ;
    @test typeof(GriddingMachine.lat_ind( 91.0)) == ErrorException;
    @test typeof(GriddingMachine.lon_ind(  0.0)) == Int           ;
    @test typeof(GriddingMachine.lon_ind(350.0)) == Int           ;
    @test typeof(GriddingMachine.lon_ind(361.0)) == ErrorException;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Load and Read datasets" begin
    println();
    TMP_LUT = load_LUT(CanopyHeightBoonman{FT}());               @test true;
    TMP_LUT = load_LUT(CanopyHeightBoonman{FT}(), 1);            @test true;
    TMP_LUT = load_LUT(CanopyHeightGLAS{FT}());                  @test true;
    CLI_PFT = load_LUT(ClumpingIndexPFT{FT}());                  @test true;
    TMP_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y");   @test true;
    TMP_LUT = load_LUT(LAIMODISv006{FT}(), 2001, "2X", "1M");    @test true;
    TMP_LUT = load_LUT(LAIMonthlyMean{FT}());                    @test true;
    TMP_LUT = load_LUT(LandMaskERA5{FT}());                      @test true;
    TMP_LUT = load_LUT(LeafNitrogenBoonman{FT}());               @test true;
    TMP_LUT = load_LUT(LeafNitrogenButler{FT}());                @test true;
    TMP_LUT = load_LUT(LeafPhosphorus{FT}());                    @test true;
    TMP_LUT = load_LUT(LeafSLABoonman{FT}());                    @test true;
    SLA_LUT = load_LUT(LeafSLAButler{FT}());                     @test true;
    TMP_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");          @test true;
    TMP_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y", 1);       @test true;
    TMP_LUT = load_LUT(VcmaxOptimalCiCa{FT}());                  @test true;
    TMP_LUT = load_LUT(WoodDensity{FT}());                       @test true;
    TMP_LUT = load_LUT(NPPModis{FT}());                          @test true;
    TMP_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "1M");      @test true;
    TMP_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "1M", 1);   @test true;
    TMP_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "5X", "8D");      @test true;
    TMP_LUT = load_LUT(SIFTropomi740{FT}(), 2018, "1X", "1M");   @test true;
    TMP_LUT = load_LUT(SIFTropomi740DC{FT}(), 2018, "1X", "1M"); @test true;
    TMP_LUT = load_LUT(SoilColor{FT}());                         @test true;
    TMP_LUT = load_LUT(VGMAlphaJules{FT}(), "12X", "1Y");        @test true;
    TMP_LUT = load_LUT(VGMLogNJules{FT}(), "12X", "1Y");         @test true;
    TMP_LUT = load_LUT(VGMThetaRJules{FT}(), "12X", "1Y");       @test true;
    TMP_LUT = load_LUT(VGMThetaSJules{FT}(), "12X", "1Y");       @test true;

    read_LUT(CLI_PFT, FT(30), FT(115), 2);                       @test true;
    read_LUT(SLA_LUT, FT(30), FT(115));                          @test true;
    read_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    read_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115)));        @test true;

    view_LUT(CLI_PFT, FT(30), FT(115), 2);                       @test true;
    view_LUT(SLA_LUT, FT(30), FT(115));                          @test true;
    view_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    view_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115)));        @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.free_memory() / 2^30) > 100
        TMP_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "240X", "1Y"); @test true;
        TMP_LUT = load_LUT(NDVIAvhrr{FT}(), 2018, "20X", "1M");     @test true;
        TMP_LUT = load_LUT(NIRoAvhrr{FT}(), 2018, "20X", "1M");     @test true;
        TMP_LUT = load_LUT(NIRvAvhrr{FT}(), 2018, "20X", "1M");     @test true;
        TMP_LUT = load_LUT(TreeDensity{FT}(), "120X", "1Y");        @test true;
        TMP_LUT = load_LUT(PFTPercentCLM{FT}());                    @test true;
        TMP_LUT = load_LUT(SurfaceAreaCLM{FT}());                   @test true;
    end
    TMP_LUT = nothing;
    CLI_PFT = nothing;
    SLA_LUT = nothing;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Mask dataset" begin
    println();
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    SLA_LUT = load_LUT(LeafSLAButler{FT}());
    mask_LUT!(CHT_LUT, [0,Inf]); @test true;
    mask_LUT!(CHT_LUT, -9999  ); @test true;
    mask_LUT!(SLA_LUT, [0,Inf]); @test true;
    mask_LUT!(SLA_LUT, -9999  ); @test true;
    CHT_LUT = nothing;
    SLA_LUT = nothing;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Regrid and Save dataset" begin
    println();
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    mask_LUT!(CHT_LUT, [0,10]);
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=true ); @test true;
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=false); @test true;
    save_LUT!(REG_LUT, "test.nc"); @test true;
    rm("test.nc");
    CHT_LUT = nothing;
    REG_LUT = nothing;
end
