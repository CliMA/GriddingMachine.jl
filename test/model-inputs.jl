weather_labels = Indexer.WeatherDriverLabels("wd1", 2020)
weather_values = reshape(Float64.(1:16), 2, 2, 4)
weather = Indexer.WeatherDrivers{Float64}(
    weather_labels,
    weather_values .+ 100_000,
    weather_values ./ 10_000,
    weather_values .+ 10,
    weather_values .+ 20,
    weather_values .+ 30,
    weather_values .+ 273.15,
    weather_values .+ 100,
    weather_values .+ 1,
)
weather_dict = Indexer.grid_weather(weather, 2, 1)
@test collect(keys(weather_dict)) == [
    "FDOY", "PATM", "PPT", "RAD_SW_DIF", "RAD_SW_DIR", "RAD_LW", "TAIR", "VPD", "WIND",
]
@test weather_dict["PATM"] == vec(weather.patm[1, 2, :])
@test weather_dict["TAIR"] == vec(weather.t_air[1, 2, :])
@test weather_dict["FDOY"] == (Float64.(collect(1:4)) .- 0.5 .- 6) ./ 24

land_labels = Indexer.LandDatasetLabels("gm1", 2020)
scalar_3d(value) = fill(Float64(value), 1, 1, 1)
soil_profile(value) = fill(Float64(value), 1, 1, 2)
seasonal(value) = fill(Float64(value), 1, 1, 12)
pft = zeros(Float64, 1, 1, 17)
pft[1, 1, 2] = 1

function land_fixture(mask_soil::Bool)
    return Indexer.LandDatasets{Float64}(
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
        fill(mask_soil, 1, 1),
        fill(!mask_soil, 1, 1),
    )
end

soil_dict = Indexer.grid_dict(land_fixture(true), 1, 1)
@test soil_dict["LATITUDE"] == -89.5
@test soil_dict["LONGITUDE"] == -179.5
@test soil_dict["SOIL_COLOR"] == 5
@test soil_dict["PFT_FRACTIONS"] == [0]
@test soil_dict["CANOPY_HEIGHT"] == 0

plant_dict = Indexer.grid_dict(land_fixture(false), 1, 1)
@test plant_dict["CANOPY_HEIGHT"] == 12
@test plant_dict["LMA"] == 0.005
@test plant_dict["PFT_FRACTIONS"][2] == 1
@test all(plant_dict["LAI"] .== 3)
@test all(plant_dict["VCMAX25"] .== 50)
@test length(plant_dict["CO2"]) == 12
