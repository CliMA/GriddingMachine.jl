using GriddingMachine
using PkgUtility
using Test

FT = Float32;
GRIDDINGMACHINE_ARTIFACTS = joinpath(@__DIR__, "../Artifacts.toml");




# test utility functions
@testset "GriddingMachine --- Lat/Lon indicies" begin
    # test the lat_ind and lon_ind
    @test typeof(lat_ind(  0.0)) == Int           ;
    @test typeof(lat_ind( 91.0)) == ErrorException;
    @test typeof(lon_ind(  0.0)) == Int           ;
    @test typeof(lon_ind(350.0)) == Int           ;
    @test typeof(lon_ind(361.0)) == ErrorException;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Load and Read datasets" begin
    @info "Downloading the artifacts, please wait...";
    predownload_artifact.(["CH_20X_1Y_V1", "CHL_2X_7D_V1", "CI_12X_1Y_V1",
                           "CI_PFT_2X_1Y_V1", "LAI_4X_1M_V1",
                           "LM_ERA5_4X_1Y_V1", "LNC_2X_1Y_V1", "LPC_2X_1Y_V1",
                           "RIVER_4X_1Y_V1", "SLA_2X_1Y_V1", "TD_12X_1Y_V1",
                           "VMAX_CICA_2X_1Y_V1", "WD_2X_1Y_V1"],
                          GRIDDINGMACHINE_ARTIFACTS);
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());                @test true;
    @show "haha";
    CLI_PFT = load_LUT(ClumpingIndexPFT{FT}());                @test true;
    @show "haha";
    CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y"); @test true;
    @show "haha";
    CHT_LUT = load_LUT(FloodPlainHeight{FT}());                @test true;
    LAI_LUT = load_LUT(LAIMonthlyMean{FT}());                  @test true;
    CHT_LUT = load_LUT(LandElevation{FT}());                   @test true;
    LMK_LUT = load_LUT(LandMaskERA5{FT}());                    @test true;
    CHL_LUT = load_LUT(LeafChlorophyll{FT}());                 @test true;
    LNC_LUT = load_LUT(LeafNitrogen{FT}());                    @test true;
    LPC_LUT = load_LUT(LeafPhosphorus{FT}());                  @test true;
    SLA_LUT = load_LUT(LeafSLA{FT}());                         @test true;
    RHT_LUT = load_LUT(RiverHeight{FT}());                     @test true;
    RLT_LUT = load_LUT(RiverLength{FT}());                     @test true;
    RMC_LUT = load_LUT(RiverManning{FT}());                    @test true;
    RWD_LUT = load_LUT(RiverWidth{FT}());                      @test true;
    TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");        @test true;
    UCA_LUT = load_LUT(UnitCatchmentArea{FT}());               @test true;
    VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());                @test true;
    WDT_LUT = load_LUT(WoodDensity{FT}());                     @test true;

    # limit the test only to latest stable julia
    if Sys.islinux() && VERSION>v"1.5"
        @info "Downloading the artifacts, please wait...";
        predownload_artifact.(["GPP_MPI_2X_1M_2005_V1", "NPP_MODIS_1X_1Y",
                               "GPP_VPM_5X_8D_2005_V1",
                               "SIF740_TROPOMI_1X_1M_2018_V1"],
                              GRIDDINGMACHINE_ARTIFACTS);
        NPP_LUT = load_LUT(NPPModis{FT}());                        @test true;
        MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "1M");    @test true;
        VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "5X", "8D");    @test true;
        SIF_LUT = load_LUT(SIFTropomi740{FT}(), 2018, "1X", "1M"); @test true;
    end

    read_LUT(CLI_PFT, FT(30), FT(115), 2); @test true;
    read_LUT(SLA_LUT, FT(30), FT(115)   ); @test true;
    read_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    read_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115))       ); @test true;

    view_LUT(CLI_PFT, FT(30), FT(115), 2); @test true;
    view_LUT(SLA_LUT, FT(30), FT(115)   ); @test true;
    view_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    view_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115))       ); @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.free_memory() / 2^30) > 100
        @info "Downloading the artifacts, please wait...";
        predownload_artifact.(["CI_240X_1Y_V1", "TD_120X_1Y_V1"],
                              GRIDDINGMACHINE_ARTIFACTS);
        CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "240X", "1Y"); @test true;
        TDT_LUT = load_LUT(TreeDensity{FT}(), "120X", "1Y");        @test true;
    end
end




# test clumping factor artifacts
@testset "GriddingMachine --- Mask dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    SLA_LUT = load_LUT(LeafSLA{FT}());
    mask_LUT!(CHT_LUT, [0,Inf]); @test true;
    mask_LUT!(CHT_LUT, -9999  ); @test true;
    mask_LUT!(SLA_LUT, [0,Inf]); @test true;
    mask_LUT!(SLA_LUT, -9999  ); @test true;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Regrid and Save dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    mask_LUT!(CHT_LUT, [0,10]);
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=true ); @test true;
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=false); @test true;
    save_LUT!(REG_LUT, "test.nc"); @test true;
    rm("test.nc");
end
