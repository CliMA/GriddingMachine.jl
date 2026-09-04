using GriddingMachine.Indexer
using OrderedCollections: OrderedDict
using Test


@testset "Indexer" verbose = true begin
    # where the test data is located
    @testset "Lat/Lon Index" begin
        @test lat_ind(-0.5, 1.0) == 90;
        @test lat_ind(0.5, 1.0) == 91;
        @test lon_ind(-0.5, 1.0) == 180;
        @test lon_ind(0.5, 1.0) == 181;
    end;

    # read the data at different levels (3D, 2D, 1D, and 1-point)
    @testset "Read Dataset" begin
        dataset = read_dataset("LAI_MODIS_2X_8D_2019_V1");
        @test size(dataset) == (720, 360, 46);
        datastd = read_dataset("LAI_MODIS_2X_8D_2019_V1"; read_std = true);
        @test size(datastd) == (720, 360, 46);
        data_2d = read_dataset("LAI_MODIS_2X_8D_2019_V1", 1);
        @test size(data_2d) == (720, 360);
        data_1d = read_dataset("LAI_MODIS_2X_8D_2019_V1", 30.25, 115.25);
        @test length(data_1d) == 46;
        data_1p = read_dataset("LAI_MODIS_2X_8D_2019_V1", 30.25, 115.25, 1);
        @test data_1p isa Number;
    end;

    # read the dataset meant for setting up the SPAC (soil-plant-air continuum) model at a specific grid
    @testset "Read Grid Dict" begin
        griddata = grid_dict(Indexer.LandDatasetLabels("gm2", 2019), 30.25, 115.25);
        @test griddata isa Dict || griddata isa OrderedDict;
        @test griddata["LAND_MASK"] > 0;
    end;

    # read the weather drivers at a specific lat/lon grid
    @testset "Read Grid Weather" begin
        gridwthd = grid_weather(Indexer.WeatherDriverLabels("wd1", 2019), 30.25, 115.25);
        @test gridwthd isa Dict || gridwthd isa OrderedDict;
        @test length(gridwthd["VPD"]) == 8760;
        @test all(.!isnan.(gridwthd["VPD"]));
    end;
end;
