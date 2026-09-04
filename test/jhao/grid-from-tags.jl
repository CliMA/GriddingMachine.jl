#=
Indexer: the tag-driven `grid_dict` / `grid_weather` methods.

These read one grid cell straight from the catalog, so the fixtures can stay at a tiny
resolution: `read_dataset(tag, lat, lon)` maps coordinates to indices from the file's own
`lat` dimension and never regrids.
=#

mktempdir() do root
    # 4 lon x 2 lat, cell centres at lon -135/-45/45/135 and lat -45/45
    nlon, nlat = 4, 2
    veg_lat, veg_lon = -45, -135     # index (1, 1)
    bare_lat, bare_lon = -45, -45    # index (2, 1)
    ocean_lat, ocean_lon = 45, 135   # index (4, 2)

    constant2d(value) = fill(Float32(value), nlon, nlat)
    function series3d(value, cycles)
        array = fill(Float32(value), nlon, nlat, cycles)
        return array
    end

    # land everywhere except the ocean cell
    land = constant2d(1)
    land[4, 2] = 0

    # LAI: vegetated at (1,1), all zero at (2,1) so the cell reads as bare soil
    lai = series3d(2.5, 12)
    lai[2, 1, :] .= 0
    # a gap inside the vegetated series, to drive gapfill_data!
    lai[1, 1, 5] = NaN32

    # PFT fractions: put everything in one C3 type for the vegetated cell
    pft = zeros(Float32, nlon, nlat, 17)
    pft[:, :, 3] .= 100

    labels = Indexer.LandDatasetLabels("gm2", 2020)
    weather_labels = Indexer.WeatherDriverLabels("wd1", 2020)

    stage_datasets!(root, Dict(
        # land parameters (gm2)
        labels.tag_t_lm   => land,
        labels.tag_p_lai  => lai,
        labels.tag_s_cc   => constant2d(5),
        labels.tag_s_α    => series3d(300, 4),
        labels.tag_s_n    => series3d(1.6, 4),
        labels.tag_s_Θr   => series3d(0.08, 4),
        labels.tag_s_Θs   => series3d(0.45, 4),
        labels.tag_p_ch   => constant2d(15),
        labels.tag_p_chl  => series3d(30, 12),
        labels.tag_p_ci   => series3d(0.8, 12),
        labels.tag_p_sla  => constant2d(20),
        labels.tag_p_vcm  => series3d(60, 12),
        labels.tag_t_ele  => constant2d(1500),
        labels.tag_t_pft  => pft,
        # weather drivers (wd1); 4 hourly steps is enough to check the shapes
        weather_labels.tag_patm    => series3d(101_325, 4),
        weather_labels.tag_ppt     => series3d(0, 4),
        weather_labels.tag_rad_dif => series3d(100, 4),
        weather_labels.tag_rad_dir => series3d(300, 4),
        weather_labels.tag_rad_lw  => series3d(350, 4),
        weather_labels.tag_t_air   => series3d(290, 4),
        weather_labels.tag_vpd     => series3d(1000, 4),
        weather_labels.tag_wind    => series3d(2, 4),
    ))

    @testset "grid_dict from labels" begin
        gm_dict = Indexer.grid_dict(labels, veg_lat, veg_lon)

        @test gm_dict["LATITUDE"] == veg_lat
        @test gm_dict["LONGITUDE"] == veg_lon
        @test gm_dict["YEAR"] == 2020
        @test gm_dict["RESO_SPACE"] == labels.nx
        @test gm_dict["ELEVATION"] ≈ 1500
        @test gm_dict["LAND_MASK"] ≈ 1
        @test gm_dict["SOIL_COLOR"] == 5
        # canopy height is floored at 0.1 m
        @test gm_dict["CANOPY_HEIGHT"] ≈ 15
        # LMA is derived from specific leaf area: 1 / SLA / 10
        @test gm_dict["LMA"] ≈ 1 / 20 / 10
        # monthly inputs are resampled onto a daily axis; 2020 is a leap year
        @test length(gm_dict["LAI"]) == 366
        @test length(gm_dict["CLUMPING"]) == 366
        @test length(gm_dict["CHLOROPHYLL"]) == 366
        @test length(gm_dict["VCMAX25"]) == 366
        # JMAX25 and B6F are fixed multiples of VCMAX25
        @test gm_dict["JMAX25"] ≈ gm_dict["VCMAX25"] .* 1.73
        @test gm_dict["B6F"] ≈ gm_dict["VCMAX25"] .* 0.0089
        # the NaN in the LAI series was gap filled before resampling
        @test !any(isnan, gm_dict["LAI"])
        @test length(gm_dict["CO2"]) == 12
        @test length(gm_dict["PFT_FRACTIONS"]) == 17
        # C4 optical properties come straight from the CLM5 table, C3 from a PFT average
        @test gm_dict["ρ_PAR_C4"] > 0
        @test gm_dict["ρ_PAR_C3"] > 0
        @test gm_dict["G1_MEDLYN_C3"] > 0
        # the dictionary keeps a stable key order
        @test gm_dict isa OrderedDict

        # the string convenience method resolves the labels itself
        @test Indexer.grid_dict("gm2", 2020, veg_lat, veg_lon)["ELEVATION"] ≈
              gm_dict["ELEVATION"]
    end

    @testset "grid_dict entry conditions" begin
        # no land at all
        @test_throws ErrorException Indexer.grid_dict(labels, ocean_lat, ocean_lon)
        # land, but no leaves in any cycle
        @test_throws ErrorException Indexer.grid_dict(labels, bare_lat, bare_lon)
    end

    @testset "grid_weather from labels" begin
        wd_dict = Indexer.grid_weather(weather_labels, veg_lat, veg_lon)

        @test Set(keys(wd_dict)) == Set([
            "FDOY", "PATM", "PPT", "RAD_SW_DIF", "RAD_SW_DIR", "RAD_LW", "TAIR", "VPD", "WIND",
        ])
        @test all(wd_dict["PATM"] .≈ 101_325)
        @test all(wd_dict["TAIR"] .≈ 290)
        @test length(wd_dict["FDOY"]) == 4
        # FDOY carries the longitude-derived time-zone offset
        @test wd_dict["FDOY"] ≈ (collect(1:4) .- 0.5 .+ veg_lon / 15) ./ 24

        # Float32 output is requested through the FT keyword
        wd32 = Indexer.grid_weather(weather_labels, veg_lat, veg_lon; FT = Float32)
        @test eltype(wd32["PATM"]) == Float32

        # the string convenience method resolves the labels itself
        @test Indexer.grid_weather("wd1", 2020, veg_lat, veg_lon)["FDOY"] ≈ wd_dict["FDOY"]
    end

    @testset "Struct constructors that read every tag" begin
        # The keyword defaults of both structs pull each tag through read_dataset and
        # regrid it onto the 1/nx degree grid, so a 4 x 2 fixture expands to 360 x 180.
        drivers = Indexer.WeatherDrivers{Float64}("wd1", 2020)
        @test drivers.LABELS.wd_tag == "wd1"
        @test size(drivers.patm) == (360, 180, 4)
        @test eltype(drivers.patm) == Float64
        @test all(drivers.patm .≈ 101_325)
        @test all(drivers.t_air .≈ 290)
        # an index-based read of the regridded field agrees with the tag-based read
        @test Indexer.grid_weather(drivers, 1, 1)["PATM"] == vec(drivers.patm[1, 1, :])

        lands = Indexer.LandDatasets{Float64}("gm2", 2020)
        @test lands.LABELS.gm_tag == "gm2"
        @test size(lands.t_lm) == (360, 180)
        @test size(lands.p_lai) == (360, 180, 12)
        @test size(lands.t_pft) == (360, 180, 17)
        # extend_data! ran as part of the constructor and classified the grid cells
        @test any(lands.mask_spac)
        @test any(lands.mask_soil)
        # the ocean cell in the fixture is in neither mask
        @test !lands.mask_spac[360, 180]
        @test !lands.mask_soil[360, 180]
    end
end
