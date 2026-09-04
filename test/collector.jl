using GriddingMachine.Collector
using Test


@testset "Collector" verbose = true begin
    # update the database
    @testset "Update Database" begin
        update_database!();
        @test "LAI_MODIS_2X_8D_2019_V1" in keys(Collector.YAML_DATABASE);
    end;

    # download a dataset
    @testset "Download Dataset" begin
        dataset_path = download_dataset!("LAI_MODIS_2X_8D_2019_V1");
        @test isfile(dataset_path);
    end;
end;
