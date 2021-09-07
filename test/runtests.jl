using GriddingMachine.Collections
using Test


# test query_collection function
@testset "GriddingMachine : Collections" begin
    query_collection(VcmaxCollection()); @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.total_memory() / 2^30) > 30
        query_collection(CanopyHeightCollection(), "20X_1Y_V1"); @test true;
        query_collection(CanopyHeightCollection(), "2X_1Y_V2" ); @test true;

        query_collection(ElevationCollection(), "4X_1Y_V1" ); @test true;

        query_collection(ClumpingIndexCollection(), "240X_1Y_V1"); @test true;
        query_collection(ClumpingIndexCollection(), "2X_1Y_V1"  ); @test true;
        query_collection(ClumpingIndexCollection(), "2X_1Y_V2"  ); @test true;

        for year in 2001:2019
            query_collection(GPPCollection(), "MPI_RS_2X_1M_$(year)_V1"); @test true;
            query_collection(GPPCollection(), "MPI_RS_2X_8D_$(year)_V1"); @test true;
        end;

        for year in 2000:2020
            query_collection(LAICollection(), "MODIS_2X_1M_$(year)_V1" ); @test true;
            query_collection(LAICollection(), "MODIS_2X_8D_$(year)_V1" ); @test true;
            query_collection(LAICollection(), "MODIS_10X_1M_$(year)_V1"); @test true;
            query_collection(LAICollection(), "MODIS_10X_8D_$(year)_V1"); @test true;
            query_collection(LAICollection(), "MODIS_20X_1M_$(year)_V1"); @test true;
            query_collection(LAICollection(), "MODIS_20X_8D_$(year)_V1"); @test true;
        end;

        query_collection(LandMaskCollection(), "4X_1Y_V1"); @test true;

        # expect warning here
        query_collection(LeafChlorophyllCollection(), "2X_7D_V1"); @test true;

        query_collection(LeafNitrogenCollection(), "2X_1Y_V1"); @test true;
        query_collection(LeafNitrogenCollection(), "2X_1Y_V2"); @test true;

        query_collection(LeafPhosphorusCollection(), "2X_1Y_V1"); @test true;

        query_collection(PFTCollection(), "2X_1Y_V1"); @test true;

        for year in 2018:2019
            query_collection(SIFCollection(), "TROPOMI_740_1X_1M_$(year)_V1"   ); @test true;
            query_collection(SIFCollection(), "TROPOMI_740_12X_8D_$(year)_V1"  ); @test true;
            query_collection(SIFCollection(), "TROPOMI_740DC_1X_1M_$(year)_V1" ); @test true;
            query_collection(SIFCollection(), "TROPOMI_740DC_12X_8D_$(year)_V1"); @test true;
        end;

        query_collection(SoilColorCollection(), "2X_1Y_V1"); @test true;

        query_collection(SoilHydraulicsCollection(), "SWCR_120X_1Y_V1"); @test true;
        query_collection(SoilHydraulicsCollection(), "SWCR_12X_1Y_V1" ); @test true;
        query_collection(SoilHydraulicsCollection(), "SWCS_120X_1Y_V1"); @test true;
        query_collection(SoilHydraulicsCollection(), "SWCS_12X_1Y_V1" ); @test true;
        query_collection(SoilHydraulicsCollection(), "VGA_120X_1Y_V1" ); @test true;
        query_collection(SoilHydraulicsCollection(), "VGA_12X_1Y_V1"  ); @test true;
        query_collection(SoilHydraulicsCollection(), "VGN_120X_1Y_V1" ); @test true;
        query_collection(SoilHydraulicsCollection(), "VGN_12X_1Y_V1"  ); @test true;

        query_collection(SpecificLeafAreaCollection(), "2X_1Y_V1"); @test true;
        query_collection(SpecificLeafAreaCollection(), "2X_1Y_V2"); @test true;

        query_collection(SurfaceAreaCollection(), "2X_1Y_V1"); @test true;
        query_collection(SurfaceAreaCollection(), "1X_1Y_V1"); @test true;

        query_collection(TreeDensityCollection(), "120X_1Y_V1"); @test true;
        query_collection(TreeDensityCollection(), "2X_1Y_V1"  ); @test true;

        query_collection(VcmaxCollection(), "2X_1Y_V1"); @test true;
        query_collection(VcmaxCollection(), "2X_1Y_V2"); @test true;

        query_collection(WoodDensityCollection(), "2X_1Y_V1"); @test true;
    end
end
