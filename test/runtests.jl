using GriddingMachine
using GriddingMachine.Blender
using GriddingMachine.Collector
using GriddingMachine.Fetcher
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using Test


@testset verbose = true "GriddingMachine" begin
    @testset "Database" begin
        # the update functions
        GriddingMachine.update_database!(); @test true;

        # the judge functions
        GriddingMachine.artifact_exists("CH_2X_1Y_V2"); @test true;
        GriddingMachine.artifact_exists("031f34db3ce1921a723d8e4151ee6c6fe5566714"); @test true;
        GriddingMachine.artifact_downloaded("CH_2X_1Y_V2"); @test true;

        # the index functions
        GriddingMachine.artifact_file("CH_2X_1Y_V2"); @test true;
        GriddingMachine.artifact_folder("CH_2X_1Y_V2"); @test true;
        GriddingMachine.artifact_sha("CH_2X_1Y_V2"); @test true;
        GriddingMachine.artifact_tags(); @test true;
        GriddingMachine.cache_folder(); @test true;
        GriddingMachine.public_folder(); @test true;
        GriddingMachine.tarball_folder(); @test true;
        GriddingMachine.tarball_folder("CH_2X_1Y_V2"); @test true;
        GriddingMachine.tarball_file("CH_2X_1Y_V2"); @test true;
    end;

    @testset "Collector" begin
        # test download_artifact! function
        Collector.download_artifact!("CH_2X_1Y_V2"); @test true;
        Collector.download_artifact!("PFT_2X_1Y_V1"); @test true;

        # clean up artifacts
        Collector.clean_database!("old"); @test true;
    end;

    @testset "Indexer" begin
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1Y_V1"));  @test true;
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1M_V3"));  @test true;
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1M_V3"), 8);  @test true;
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1M_V3"), 30, 116);  @test true;
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1M_V3"), 30, 116; interpolation = true);  @test true;
        Indexer.read_LUT(Collector.download_artifact!("CI_2X_1M_V3"), 30, 116, 8);  @test true;
        Indexer.read_LUT(Collector.download_artifact!("REFLECTANCE_MCD43A4_B1_1X_1M_2000_V1"), 30, 116, 8);  @test true;
    end;

    @testset "Blender" begin
        Blender.regrid(rand(720,360), 1); @test true;
        Blender.regrid(rand(720,360,2), 1); @test true;
        Blender.regrid(rand(360,180), 2); @test true;
        Blender.regrid(rand(360,180,2), 2); @test true;
        Blender.regrid(rand(360,180), (144,96)); @test true;
        Blender.regrid(rand(360,180,2), (144,96)); @test true;
    end;

    @testset "Requestor" begin
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8); @test true;
        Requestor.request_LUT("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true); @test true;
    end;

    #=
    @testset "Partitioner" begin
        if Sys.islinux() && (Sys.total_memory() / 2^30) > 64
            folder = "/net/fluo/data2/pool/database/GriddingMachine/test/partitioner_tests/"
            Partitioner.partition_from_json(folder * "partition_test_random.json"); @test true;
            Partitioner.clean_files(folder * "partition_test_random.json", 2023; months = [1]); @test true;
            Partitioner.partition_from_json(folder * "partition_test_oco2.json"); @test true;
            Partitioner.get_data_from_json(folder * "partition_test_oco2.json", [-50.1 -19.8; 70.2 -18.2; 60.3 12.2; -40.7 11.4], 2022); @test true;
            Partitioner.clean_files(folder * "partition_test_oco2.json", 2022; months = [1]); @test true;
            rm(folder * "partitioned_files"; recursive = true); @test true;
        end;
    end;
    =#
end;
