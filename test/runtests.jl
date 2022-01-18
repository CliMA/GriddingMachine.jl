using GriddingMachine.Blender
using GriddingMachine.Collector
using GriddingMachine.Fetcher
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using Test


# test Collector functions
println();
@testset "GriddingMachine : Library" begin
    canopy_height_collection();    @test true;
    clumping_index_collection();   @test true;
    elevation_collection();        @test true;
    gpp_collection();              @test true;
    lai_collection();              @test true;
    land_mask_collection();        @test true;
    leaf_chlorophyll_collection(); @test true;
    leaf_nitrogen_collection();    @test true;
    leaf_phosphorus_collection();  @test true;
    pft_collection();              @test true;
    sif_collection();              @test true;
    sil_collection();              @test true;
    sla_collection();              @test true;
    soil_color_collection();       @test true;
    soil_hydraulics_collection();  @test true;
    surface_area_collection();     @test true;
    tree_density_collection();     @test true;
    vcmax_collection();            @test true;
    wood_density_collection();     @test true;

    # test the @show function
    @show wood_density_collection(); @test true;
end;


println();
@testset "GriddingMachine : Collector" begin
    # test query_collection function
    query_collection(pft_collection()); @test true;
    query_collection(sla_collection()); @test true;
    query_collection("PFT_2X_1Y_V1"); @test true;

    # sync collection
    sync_collections!(sla_collection());

    # clean up artifacts
    clean_collections!("old"); @test true;
    clean_collections!(pft_collection()); @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.total_memory() / 2^30) > 64
        query_collection(biomass_collection(), "ROOT_120X_1Y_V1" ); @test true;
        query_collection(biomass_collection(), "SHOOT_120X_1Y_V2"); @test true;

        query_collection(canopy_height_collection(), "20X_1Y_V1"); @test true;
        query_collection(canopy_height_collection(), "2X_1Y_V2" ); @test true;

        query_collection(elevation_collection(), "4X_1Y_V1" ); @test true;

        query_collection(clumping_index_collection(), "240X_1Y_V1"); @test true;
        query_collection(clumping_index_collection(), "2X_1Y_V1"  ); @test true;
        query_collection(clumping_index_collection(), "2X_1Y_V2"  ); @test true;

        for year in 2001:2019
            query_collection(gpp_collection(), "MPI_RS_2X_1M_$(year)_V1"); @test true;
            query_collection(gpp_collection(), "MPI_RS_2X_8D_$(year)_V1"); @test true;
        end;
        for year in 2000:2019
            query_collection(gpp_collection(), "VPM_5X_8D_$(year)_V2" ); @test true;
            query_collection(gpp_collection(), "VPM_12X_8D_$(year)_V2"); @test true;
        end;

        for year in 2000:2020
            query_collection(lai_collection(), "MODIS_2X_1M_$(year)_V1" ); @test true;
            query_collection(lai_collection(), "MODIS_2X_8D_$(year)_V1" ); @test true;
            query_collection(lai_collection(), "MODIS_10X_1M_$(year)_V1"); @test true;
            query_collection(lai_collection(), "MODIS_10X_8D_$(year)_V1"); @test true;
            query_collection(lai_collection(), "MODIS_20X_1M_$(year)_V1"); @test true;
            query_collection(lai_collection(), "MODIS_20X_8D_$(year)_V1"); @test true;
        end;

        query_collection(land_mask_collection(), "4X_1Y_V1"); @test true;

        # expect warning here
        query_collection(leaf_chlorophyll_collection(), "2X_7D_V1"); @test true;

        query_collection(leaf_nitrogen_collection(), "2X_1Y_V1"); @test true;
        query_collection(leaf_nitrogen_collection(), "2X_1Y_V2"); @test true;

        query_collection(leaf_phosphorus_collection(), "2X_1Y_V1"); @test true;

        query_collection(pft_collection(), "2X_1Y_V1"); @test true;

        for year in 2018:2020
            query_collection(sif_collection(), "TROPOMI_740_1X_1M_$(year)_V1"   ); @test true;
            query_collection(sif_collection(), "TROPOMI_740_1X_8D_$(year)_V1"   ); @test true;
            query_collection(sif_collection(), "TROPOMI_740_5X_1M_$(year)_V1"   ); @test true;
            query_collection(sif_collection(), "TROPOMI_740_5X_8D_$(year)_V1"   ); @test true;
            query_collection(sif_collection(), "TROPOMI_740_12X_1M_$(year)_V1"  ); @test true;
            query_collection(sif_collection(), "TROPOMI_740_12X_8D_$(year)_V1"  ); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_1X_1M_$(year)_V1" ); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_1X_8D_$(year)_V1" ); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_5X_1M_$(year)_V1" ); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_5X_8D_$(year)_V1" ); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_12X_1M_$(year)_V1"); @test true;
            query_collection(sif_collection(), "TROPOMI_740DC_12X_8D_$(year)_V1"); @test true;
        end;
        for year in 2019:2019
            query_collection(sif_collection(), "TROPOMI_683_5X_1M_$(year)_V2"  ); @test true;
            query_collection(sif_collection(), "TROPOMI_683_5X_8D_$(year)_V2"  ); @test true;
            query_collection(sif_collection(), "TROPOMI_683DC_5X_1M_$(year)_V2"); @test true;
            query_collection(sif_collection(), "TROPOMI_683DC_5X_8D_$(year)_V2"); @test true;
        end;
        for year in 2014:2020
            query_collection(sif_collection(), "OCO2_757_5X_1M_$(year)_V3"  ); @test true;
            query_collection(sif_collection(), "OCO2_771_5X_1M_$(year)_V3"  ); @test true;
            query_collection(sif_collection(), "OCO2_757DC_5X_1M_$(year)_V3"); @test true;
            query_collection(sif_collection(), "OCO2_771DC_5X_1M_$(year)_V3"); @test true;
        end;

        query_collection(sil_collection(), "20X_1Y_V1"); @test true;

        query_collection(sla_collection(), "2X_1Y_V1"); @test true;
        query_collection(sla_collection(), "2X_1Y_V2"); @test true;

        query_collection(soil_color_collection(), "2X_1Y_V1"); @test true;

        query_collection(soil_hydraulics_collection(), "SWCR_120X_1Y_V1"); @test true;
        query_collection(soil_hydraulics_collection(), "SWCR_12X_1Y_V1" ); @test true;
        query_collection(soil_hydraulics_collection(), "SWCS_120X_1Y_V1"); @test true;
        query_collection(soil_hydraulics_collection(), "SWCS_12X_1Y_V1" ); @test true;
        query_collection(soil_hydraulics_collection(), "VGA_120X_1Y_V1" ); @test true;
        query_collection(soil_hydraulics_collection(), "VGA_12X_1Y_V1"  ); @test true;
        query_collection(soil_hydraulics_collection(), "VGN_120X_1Y_V1" ); @test true;
        query_collection(soil_hydraulics_collection(), "VGN_12X_1Y_V1"  ); @test true;
        query_collection(soil_hydraulics_collection(), "KSAT_100X_1Y_V2"); @test true;

        query_collection(surface_area_collection(), "2X_1Y_V1"); @test true;
        query_collection(surface_area_collection(), "1X_1Y_V1"); @test true;

        query_collection(tree_density_collection(), "120X_1Y_V1"); @test true;
        query_collection(tree_density_collection(), "2X_1Y_V1"  ); @test true;

        query_collection(vcmax_collection(), "2X_1Y_V1"); @test true;
        query_collection(vcmax_collection(), "2X_1Y_V2"); @test true;

        query_collection(wood_density_collection(), "2X_1Y_V1"); @test true;
    end;
end;


# test Requestor functions
println();
@testset "GriddingMachine : Blender" begin
    regrid(rand(720,360), 1); @test true;
    regrid(rand(720,360,2), 1); @test true;
end;


# test Indexer functions
println();
@testset "GriddingMachine : Indexer" begin
    # read the full dataset
    read_LUT(query_collection(vcmax_collection())); @test true;

    # read the global map at a given cycle index
    read_LUT(query_collection(gpp_collection()), 8); @test true;

    # read the data at given lat and lon
    read_LUT(query_collection(vcmax_collection()), 30, 116); @test true;
    read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5); @test true;
    read_LUT(query_collection(vcmax_collection()), 30, 116; interpolation=true); @test true;
    read_LUT(query_collection(vcmax_collection()), 30, 116, 0.5; interpolation=true); @test true;

    # read the data at given lat, lon, and cycle index
    read_LUT(query_collection(gpp_collection()), 30, 116, 8); @test true;
    read_LUT(query_collection(gpp_collection()), 30, 116, 8, 0.5); @test true;
    read_LUT(query_collection(gpp_collection()), 30, 116, 8; interpolation=true); @test true;
    read_LUT(query_collection(gpp_collection()), 30, 116, 8, 0.5; interpolation=true); @test true;
end;


# test Requestor functions
println();
@testset "GriddingMachine : Requestor" begin
    # only for high memory and storage cases, e.g., server
    if Sys.islinux()
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true); @test true;
    end;
end;
