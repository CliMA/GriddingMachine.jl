#= Indexer: dataset labels, CO2 lookup, and the gap-filling pass over LandDatasets =#

@testset "Dataset labels" begin
    gm1 = Indexer.LandDatasetLabels("gm1", 2020)
    @test gm1.gm_tag == "gm1"
    @test gm1.nx == 1
    # the LAI tag carries the year, everything else is year independent
    @test gm1.tag_p_lai == "LAI_MODIS_2X_8D_2020_V1"
    @test gm1.tag_t_lm == "LM_4X_1Y_V1"

    gm2 = Indexer.LandDatasetLabels("gm2", 2020)
    # gm2 differs from gm1 only in the clumping index product
    @test gm2.tag_p_ci == "CI_2X_1M_V3"
    @test gm1.tag_p_ci == "CI_2X_1Y_V1"
    @test gm2.tag_p_lai == gm1.tag_p_lai

    @test_throws AssertionError Indexer.LandDatasetLabels("gm9", 2020)

    wd1 = Indexer.WeatherDriverLabels("wd1", 2020)
    @test wd1.wd_tag == "wd1"
    @test wd1.tag_t_air == "TAIR_ERA5_1X_1H_2020_V1"
    @test_throws AssertionError Indexer.WeatherDriverLabels("wd9", 2020)
end

@testset "CO2 concentration lookup" begin
    # yearly mean
    @test Indexer.CO₂_ppm(2020) ≈ 414.21
    # single month
    @test Indexer.CO₂_ppm(2020, 6) ≈ 416.60 atol = 1.0
    # a complete year returns twelve monthly means
    @test length(Indexer.CO₂_ppm(2020, true)) == 12
    # an incomplete year is padded with its last available month
    partial = Indexer.CO₂_ppm(2025, true)
    @test length(partial) == 12
    @test partial[12] == partial[10]
    # a year outside the record is an error rather than an empty vector
    @test_throws ErrorException Indexer.CO₂_ppm(1800, true)
end

@testset "extend_data! gap filling" begin
    labels = Indexer.LandDatasetLabels("gm1", 2020)

    # Three cells side by side: vegetated, bare soil, and ocean.
    # lon index 1 = vegetated (land, positive LAI)
    # lon index 2 = bare soil (land, LAI all zero)
    # lon index 3 = ocean (no land)
    t_lm = reshape(Float64[1, 1, 0], 3, 1)
    p_lai = zeros(Float64, 3, 1, 4)
    p_lai[1, 1, :] .= [1.0, NaN, 3.0, NaN]   # NaNs inside a vegetated series
    p_lai[2, 1, :] .= [0.0, 0.0, 0.0, 0.0]   # no leaves at all -> bare soil
    p_lai[3, 1, :] .= NaN                    # ocean stays untouched

    plant_layer(value) = reshape(Float64[value, value, value], 3, 1, 1)
    soil_layer(value) = cat(plant_layer(value), plant_layer(value); dims = 3)

    dts = Indexer.LandDatasets{Float64}(
        LABELS    = labels,
        s_cc      = plant_layer(5),
        s_α       = fill(NaN, 3, 1, 2),
        s_n       = fill(NaN, 3, 1, 2),
        s_Θr      = fill(NaN, 3, 1, 2),
        s_Θs      = fill(NaN, 3, 1, 2),
        p_ch      = plant_layer(NaN),
        p_chl     = plant_layer(NaN),
        p_ci      = plant_layer(NaN),
        p_lai     = p_lai,
        p_sla     = plant_layer(NaN),
        p_vcm     = plant_layer(NaN),
        t_ele     = plant_layer(100),
        t_lm      = t_lm,
        t_pft     = zeros(Float64, 3, 1, 17),
        mask_soil = zeros(Bool, 3, 1),
        mask_spac = zeros(Bool, 3, 1),
    )
    # every plant field is NaN, so a mean-based fill has nothing to work from;
    # give p_ch one finite value so nanmean is defined for that field
    dts.p_ch[1, 1, 1] = 12.0

    @test isnothing(Indexer.extend_data!(dts))

    # masks: exactly one vegetated cell, one bare soil cell, ocean in neither
    @test dts.mask_spac == reshape(Bool[1, 0, 0], 3, 1)
    @test dts.mask_soil == reshape(Bool[0, 1, 0], 3, 1)

    # NaNs inside the vegetated LAI series are filled, and land LAI has no NaN left
    @test !any(isnan, dts.p_lai[1, 1, :])
    @test !any(isnan, dts.p_lai[2, 1, :])
    # the ocean cell is not a land grid, so it is left as is
    @test all(isnan, dts.p_lai[3, 1, :])

    # soil van Genuchten parameters fall back to Loam for land cells
    @test dts.s_α[1, 1, 1] ≈ 367.3476
    @test dts.s_n[1, 1, 1] ≈ 1.56
    @test dts.s_Θr[1, 1, 1] ≈ 0.078
    @test dts.s_Θs[1, 1, 1] ≈ 0.43
    @test dts.s_α[2, 1, 1] ≈ 367.3476
    # the ocean cell is in neither mask and keeps its NaN
    @test isnan(dts.s_α[3, 1, 1])

    # plant fields are filled with the field mean over vegetated cells
    @test dts.p_ch[1, 1, 1] ≈ 12.0
    # t_ele, t_lm, t_pft and the masks are explicitly excluded from gap filling
    @test dts.t_ele == plant_layer(100)
    @test dts.t_lm == t_lm
end
