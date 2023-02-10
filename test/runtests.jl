using GriddingMachine.Blender
using GriddingMachine.Collector
using GriddingMachine.Fetcher
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using NetcdfIO: varname_nc
using Test


@testset verbose = true "GriddingMachine" begin
    collections = [biomass_collection(),
                   canopy_height_collection(),
                   clumping_index_collection(),
                   elevation_collection(),
                   gpp_collection(),
                   lai_collection(),
                   land_mask_collection(),
                   latent_heat_collection(),
                   leaf_chlorophyll_collection(),
                   leaf_drymass_collection(),
                   leaf_nitrogen_collection(),
                   leaf_phosphorus_collection(),
                   pft_collection(),
                   sif_collection(),
                   sil_collection(),
                   sla_collection(),
                   soil_color_collection(),
                   soil_hydraulics_collection(),
                   surface_area_collection(),
                   tree_density_collection(),
                   vcmax_collection(),
                   vegetation_cover_fraction(),
                   wood_density_collection()];

    @testset "Library" begin
        # test the collection functions
        for collection in collections
            @test true;
        end;

        # test the @show function
        @show wood_density_collection(); @test true;
    end;

    @testset "Collector" begin
        # test query_collection function
        query_collection(pft_collection()); @test true;
        query_collection(sla_collection()); @test true;
        query_collection("PFT_2X_1Y_V1"); @test true;

        # sync collection
        sync_collections!(sla_collection());

        # clean up artifacts
        clean_collections!("old"); @test true;
        clean_collections!(pft_collection()); @test true;
    end;

    @testset "Blender" begin
        regrid(rand(720,360), 1); @test true;
        regrid(rand(720,360,2), 1); @test true;
    end;

    @testset "Indexer" begin
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

    @testset "Requestor" begin
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8); @test true;
        request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true); @test true;
    end;

    @testset "Verification" begin
        # only for high memory and storage cases, e.g., server
        if Sys.islinux() && (Sys.total_memory() / 2^30) > 64
            for collection in collections
                for tag in collection.SUPPORTED_COMBOS
                    fn = query_collection(collection, tag);
                    vars = varname_nc(fn);
                    @test 4 <= length(vars) <= 5;
                    if length(vars) == 4
                        @test sort(vars) == ["data", "lat", "lon", "std"];
                    end;
                    if length(vars) == 5
                        @test sort(vars) == ["data", "ind", "lat", "lon", "std"];
                    end;
                end;
            end;
        end;
    end;
end;
