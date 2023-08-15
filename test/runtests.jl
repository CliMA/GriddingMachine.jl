using GriddingMachine.Blender
using GriddingMachine.Collector
using GriddingMachine.Fetcher
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using GriddingMachine.Processer
using GriddingMachine.Partitioner
using Test


@testset verbose = true "GriddingMachine" begin
    collections = [Collector.biomass_collection(),
                   Collector.canopy_height_collection(),
                   Collector.clumping_index_collection(),
                   Collector.elevation_collection(),
                   Collector.gpp_collection(),
                   Collector.lai_collection(),
                   Collector.land_mask_collection(),
                   Collector.latent_heat_collection(),
                   Collector.leaf_chlorophyll_collection(),
                   Collector.leaf_drymass_collection(),
                   Collector.leaf_nitrogen_collection(),
                   Collector.leaf_phosphorus_collection(),
                   Collector.pft_collection(),
                   Collector.sif_collection(),
                   Collector.sil_collection(),
                   Collector.sla_collection(),
                   Collector.soil_color_collection(),
                   Collector.soil_hydraulics_collection(),
                   Collector.soil_texture_collection(),
                   Collector.surface_area_collection(),
                   Collector.tree_density_collection(),
                   Collector.vcmax_collection(),
                   Collector.vegetation_cover_fraction(),
                   Collector.wood_density_collection()];

    @testset "Library" begin
        # test the collection functions
        for collection in collections
            @test true;
        end;

        # test the @show function
        @show Collector.wood_density_collection(); @test true;
    end;

    @testset "Collector" begin
        # test query_collection function
        Collector.query_collection(Collector.pft_collection()); @test true;
        Collector.query_collection(Collector.sla_collection()); @test true;
        Collector.query_collection("PFT_2X_1Y_V1"); @test true;

        # sync collection
        Collector.sync_collections!(Collector.sla_collection());

        # clean up artifacts
        Collector.clean_collections!("old"); @test true;
        Collector.clean_collections!(Collector.pft_collection()); @test true;
    end;

    @testset "Blender" begin
        Blender.regrid(rand(720,360), 1); @test true;
        Blender.regrid(rand(720,360,2), 1); @test true;
        Blender.regrid(rand(360,180), 2); @test true;
        Blender.regrid(rand(360,180,2), 2); @test true;
        Blender.regrid(rand(360,180), (144,96)); @test true;
        Blender.regrid(rand(360,180,2), (144,96)); @test true;
    end;

    @testset "Indexer" begin
        # read the full dataset
        Indexer.read_LUT(Collector.query_collection(Collector.vcmax_collection())); @test true;

        # read the global map at a given cycle index
        Indexer.read_LUT(Collector.query_collection(Collector.gpp_collection()), 8); @test true;

        # read the data at given lat and lon
        Indexer.read_LUT(Collector.query_collection(Collector.vcmax_collection()), 30, 116); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.vcmax_collection()), 30, 116, 0.5); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.vcmax_collection()), 30, 116; interpolation=true); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.vcmax_collection()), 30, 116, 0.5; interpolation=true); @test true;

        # read the data at given lat, lon, and cycle index
        Indexer.read_LUT(Collector.query_collection(Collector.gpp_collection()), 30, 116, 8); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.gpp_collection()), 30, 116, 8, 0.5); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.gpp_collection()), 30, 116, 8; interpolation=true); @test true;
        Indexer.read_LUT(Collector.query_collection(Collector.gpp_collection()), 30, 116, 8, 0.5; interpolation=true); @test true;
    end;

    @testset "Requestor" begin
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true); @test true;
    end;

    @testset "Processer" begin
        @test isequal(Processer.reprocess_from_json("processer_tests/testdata_correct.json")[1], Processer.reprocess_from_json("processer_tests/testdata_reorder.json")[1]);
        @test isequal(Processer.reprocess_from_json("processer_tests/testdata_correct.json")[1], Processer.reprocess_from_json("processer_tests/testdata_rescale.json")[1]);
        rm("processer_tests/TESTDATA_CORRECT_1X_1M_V1.nc"); @test true;
        rm("processer_tests/TESTDATA_REORDER_1X_1M_V1.nc"); @test true;
        rm("processer_tests/TESTDATA_RESCALE_1X_1M_V1.nc"); @test true;
    end;

    @testset "Partitioner" begin
        Partitioner.partition_from_json("partitioner_tests/partition_test.json"); @test true;
        Partitioner.get_data_from_json("partitioner_tests/partition_test.json", [-5.1 -9.8; 7.2 -8.2; 6.3 2.2; -4.7 1.4], 2023); @test true;
        Partitioner.clean_files("partitioner_tests/partition_test.json", 2023; [1]); @test true;
    end;

    @testset "Verification" begin
        # only for high memory and storage cases, e.g., server
        if Sys.islinux() && (Sys.total_memory() / 2^30) > 64 && homedir() == "/home/wyujie"
            for collection in collections
                for tag in collection.SUPPORTED_COMBOS
                    fn = Collector.query_collection(collection, tag);
                    vars = Indexer.varname_nc(fn);
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
