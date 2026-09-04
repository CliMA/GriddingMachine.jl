using Emerald
using GriddingMachine
using GriddingMachine.Indexer
using Test

@testset "Emerald minimal initialization" begin
    land_labels = Indexer.LandDatasetLabels("gm1", 2020)
    scalar_3d(value) = fill(Float64(value), 1, 1, 1)
    soil_profile(value) = fill(Float64(value), 1, 1, 4)
    seasonal(value) = fill(Float64(value), 1, 1, 12)
    pft = zeros(Float64, 1, 1, 17)
    pft[1, 1, 2] = 1
    land = Indexer.LandDatasets{Float64}(
        land_labels,
        scalar_3d(5),
        soil_profile(0.01),
        soil_profile(1.5),
        soil_profile(0.05),
        soil_profile(0.45),
        scalar_3d(12),
        seasonal(30),
        seasonal(0.8),
        seasonal(3),
        scalar_3d(20),
        seasonal(50),
        fill(100.0, 1, 1),
        scalar_3d(1),
        pft,
        falses(1, 1),
        trues(1, 1),
    )
    grid = Indexer.grid_dict(land, 1, 1)

    weather_labels = Indexer.WeatherDriverLabels("wd1", 2020)
    two_steps(value) = fill(Float64(value), 1, 1, 2)
    weather = Indexer.WeatherDrivers{Float64}(
        weather_labels,
        two_steps(101_325),
        two_steps(0),
        two_steps(20),
        two_steps(100),
        two_steps(300),
        two_steps(290),
        two_steps(1_000),
        two_steps(2),
    )
    drivers = Indexer.grid_weather(weather, 1, 1)
    @test drivers isa Dict{String,Vector{Float64}}

    config = Emerald.Namespace.SPACConfig(Float64)
    config.CONFIG_INFO.MESSAGE_LEVEL = 0
    spac = Emerald.Land.site_spac(config, grid)
    driver = Emerald.Land.site_driver_tuple(grid, drivers)
    Emerald.Land.prescribe!(config, spac, driver, 1; initialize_state = true)
    @test all(isfinite, spac.airs[1].state.ns)
    @test isfinite(spac.airs[1].state.p_air)

    Emerald.SPAC.soil_plant_air_continuum!(config, spac, 60.0)
    @test all(air -> all(isfinite, air.state.ns) && isfinite(air.state.p_air), spac.airs)
    @test all(soil -> all(isfinite, soil.state.ns), spac.soils)
end
