using GriddingMachine
using GriddingMachine.Collector
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using GriddingMachine.Server
using Test


GRIDDINGMACHINE_HOME = joinpath(homedir(), "GriddingMachine");
YAML_FILE = joinpath(homedir(), "GriddingMachine", "Artifacts.yaml");
test_tag = "CH_2X_1Y_V2"


@testset verbose = true "GriddingMachine" begin
    @testset "Server & Requestor" begin
        # up the server
        Server.setup_url_input_routes!(["testuser"]);
        Server.up_servers!(5055);
        @test true;

        # test the request_site_data function
        (data,stdv) = Requestor.request_site_data("http://localhost:5055", "testuser", "LM_4X_1Y_V1", 30.5, 115.5, 0);
        @test !isnan(data);
        @test isnan(stdv) || isnothing(stdv);

        # down the server
        Server.down_servers!();
        @test true;
    end;
    
    @testset "Collector" verbose = true begin

        # 1. Test the database management function
        # corresponding file: database-initialize.jl, database-download.jl, database-load.jl, database-update.jl
        @testset "Database Management" begin
            # Test initialization: Check if the folder has been created
            Collector.initialize_database!();
            @test isdir(GRIDDINGMACHINE_HOME);
            @test isdir(joinpath(GRIDDINGMACHINE_HOME, "cache"));
            @test isdir(joinpath(GRIDDINGMACHINE_HOME, "public"));

            # Test Download Database: Check if Artifacts.yaml exists
            Collector.download_database!();
            @test isfile(YAML_FILE);

            # Test loading database: check if the return value is correct
            (db, tags) = Collector.load_database!();
            @test isa(db, Dict);
            @test isa(tags, Vector{String});
            @test !isempty(tags);

            # Test the overall update process
            Collector.update_database!();
            @test true;
        end;

        # 2. Test dataset metadata query
        # corresponding file: dataset-info.jl
        @testset "Dataset Info" begin
            
            # Ensure that the tag exists in the database
            if Collector.dataset_found(test_tag)
                # Test path generation functions
                @test Collector.dataset_found(test_tag);
                @test !isempty(Collector.dataset_url(test_tag));
                
                # Check if the generated path format ends in .nc
                @test endswith(Collector.dataset_path(test_tag), ".nc");
                @test endswith(Collector.dataset_cache(test_tag), ".nc");
                
                # Check if the directory path is valid
                dir_path = Collector.dataset_dir(test_tag);
                @test isdir(dir_path);
            else
                @warn "Test tag $test_tag not found in database."
            end
        end;

        # 3. Test dataset download
        # corresponding file: dataset-download.jl
        @testset "Dataset Download" begin
            test_tag = "CH_2X_1Y_V2";
            
            if Collector.dataset_found(test_tag)
                # Execute download (this will generate a network request)
                path = Collector.download_dataset!(test_tag);
                
                # Check if the downloaded file exists
                @test isfile(path);
                
                # Verify that the returned path matches the expected dataset path
                @test Collector.download_dataset!(test_tag) == path;
            end
        end;

        # 4. Test local file tree query
        # corresponding file: database-tree.jl
        @testset "Database Tree" begin
            # Obtain a list of all the latest data paths in theory
            latest = Collector.latest_datasets();
            @test isa(latest, Vector{String});
            
            # Retrieve the list of files that actually exist locally
            local_files = Collector.local_datasets();
            @test isa(local_files, Vector{String});
            
            # Because we just downloaded CH2X_1YV2, the local list should not be empty
            @test !isempty(local_files);
        end;

        # 5. Test database cleaning
        # corresponding file: database-clean.jl
        @testset "Clean Database" begin
            # Test cleaning expired files (old)
            Collector.clean_database!("old");
            @test true;

            # Test cleaning specified files (optional test: clean the test file just downloaded, restore environment)
            Collector.clean_database!([test_tag]);
            @test !isfile(Collector.dataset_path(test_tag));
        end;
    end;
        
end;
#=
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
        Indexer.read_LUT("CI_2X_1Y_V1"); @test true;
        Indexer.read_LUT("CI_2X_1M_V3"); @test true;
        Indexer.read_LUT("CI_2X_1M_V3", 8); @test true;
        Indexer.read_LUT("CI_2X_1M_V3", 30, 116); @test true;
        Indexer.read_LUT("CI_2X_1M_V3", 30, 116; interpolation = true); @test true;
        Indexer.read_LUT("CI_2X_1M_V3", 30, 116, 8); @test true;
        Indexer.read_LUT("REFLECTANCE_MCD43A4_B1_1X_1M_2000_V1", 30, 116, 8); @test true;
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
        Requestor.request_site_data("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5); @test true;
        Requestor.request_site_data("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5; interpolation=true); @test true;
        Requestor.request_site_data("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8); @test true;
        Requestor.request_site_data("LAI_MODIS_2X_8D_2017_V1", 30.5, 115.5, 8; interpolation=true); @test true;
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
=#
