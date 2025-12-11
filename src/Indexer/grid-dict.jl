"""

    grid_dict(dts::LandDatasets{FT}, ilat::Int, ilon::Int; verification::Bool = true) where {FT}
    grid_dict(dtl::LandDatasetLabels, lat::Number, lon::Number; FT::DataType = Float64, verification::Bool = true)

Prepare a dictionary of GriddingMachine data to feed SPAC, given
- `dts` `LandDatasets` type data struct
- `ilat` latitude index
- `ilon` longitude index
- `verification` verify the dictionary per key and value to make sure there is not NaN
- `dtl` `LandDatasetLabels` type data struct
- `year` year of the datasets
- `nx` grid resolution (1/nx °)
- `lat` latitude
- `lon` longitude

"""
function grid_dict end;

grid_dict(dts::LandDatasets{FT}, ilat::Int, ilon::Int; verification::Bool = true) where {FT} = (
    reso   = 1 / dts.LABELS.nx;
    co2    = CO₂_ppm(dts.LABELS.year, true);
    lmsk   = dts.t_lm[ilon,ilat,1];
    scolor = min(20, max(1, Int(floor(dts.s_cc[ilon,ilat,1]))));
    s_α    = dts.s_α[ilon,ilat,:];
    s_n    = dts.s_n[ilon,ilat,:];
    s_Θr   = dts.s_Θr[ilon,ilat,:];
    s_Θs   = dts.s_Θs[ilon,ilat,:];

    # return the grid dictionary if the grid is masked as soil
    if dts.mask_soil[ilon,ilat]
        gm_dict = Dict{String,Any}(
                    "B6F"           => resample(0, "1D", dts.LABELS.year),
                    "CANOPY_HEIGHT" => 0,
                    "CHLOROPHYLL"   => resample(0, "1D", dts.LABELS.year),
                    "CLUMPING"      => resample(1, "1D", dts.LABELS.year),
                    "CO2"           => co2,
                    "ELEVATION"     => dts.t_ele[ilon,ilat],
                    "G1_MEDLYN_C3"  => 0,
                    "G1_MEDLYN_C4"  => 0,
                    "JMAX25"        => resample(0, "1D", dts.LABELS.year),
                    "LAI"           => resample(0, "1D", dts.LABELS.year),
                    "LAND_MASK"     => lmsk,
                    "LATITUDE"      => (ilat - 0.5) * reso - 90,
                    "LAT_INDEX"     => ilat,
                    "LMA"           => 0,
                    "LONGITUDE"     => (ilon - 0.5) * reso - 180,
                    "LON_INDEX"     => ilon,
                    "PFT_FRACTIONS" => [0],
                    "RESO_SPACE"    => dts.LABELS.nx,
                    "SAI"           => 0,
                    "SOIL_COLOR"    => scolor,
                    "SOIL_N"        => s_n,
                    "SOIL_α"        => s_α,
                    "SOIL_ΘR"       => s_Θr,
                    "SOIL_ΘS"       => s_Θs,
                    "VCMAX25"       => resample(0, "1D", dts.LABELS.year),
                    "YEAR"          => dts.LABELS.year,
                    "ρ_NIR_C3"      => 0,
                    "ρ_NIR_C4"      => 0,
                    "ρ_PAR_C3"      => 0,
                    "ρ_PAR_C4"      => 0,
                    "τ_NIR_C3"      => 0,
                    "τ_NIR_C4"      => 0,
                    "τ_PAR_C3"      => 0,
                    "τ_PAR_C4"      => 0);
        verification ? (@assert NaN_test(gm_dict) "gm_dict contains NaN values") : nothing;

        return gm_dict
    end;

    # else return the grid dictionary if the grid is masked as plant
    chls  = dts.p_chl[ilon,ilat,:];
    cis   = dts.p_ci[ilon,ilat,:];
    lais  = dts.p_lai[ilon,ilat,:];
    lma   = 1 / dts.p_sla[ilon,ilat,1] / 10;
    pfts  = dts.t_pft[ilon,ilat,:];
    vcmax = dts.p_vcm[ilon,ilat,:];
    zc    = dts.p_ch[ilon,ilat,1];

    # gap fill the data for seasonal trends
    gapfill_data!(chls);
    gapfill_data!(cis);
    gapfill_data!(lais);
    gapfill_data!(vcmax);

    # compute g1 for Medlyn model
    ind_c3 = [2:14;16;17];
    ind_c4 = 15;
    ind_plant = [2:14;16;17];

    g1_c3_medlyn = CLM5_PFTG[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    if isnan(g1_c3_medlyn) g1_c3_medlyn = nanmean(CLM5_PFTG[ind_c3]) end;
    g1_c4_medlyn = CLM5_PFTG[ind_c4];

    # broadband leaf optical properties
    ρ_par = CLM5_ρPAR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    τ_par = CLM5_τPAR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    ρ_nir = CLM5_ρNIR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    τ_nir = CLM5_τNIR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    if isnan(ρ_par) ρ_par = nanmean(CLM5_ρPAR[ind_plant]) end;
    if isnan(τ_par) τ_par = nanmean(CLM5_τPAR[ind_plant]) end;
    if isnan(ρ_nir) ρ_nir = nanmean(CLM5_ρNIR[ind_plant]) end;
    if isnan(τ_nir) τ_nir = nanmean(CLM5_τNIR[ind_plant]) end;

    # compute the leaf optical properties for C3 and C4 separately
    ρ_par_c3 = CLM5_ρPAR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    τ_par_c3 = CLM5_τPAR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    ρ_nir_c3 = CLM5_ρNIR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    τ_nir_c3 = CLM5_τNIR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    if isnan(ρ_par_c3) ρ_par_c3 = nanmean(CLM5_ρPAR[ind_c3]) end;
    if isnan(τ_par_c3) τ_par_c3 = nanmean(CLM5_τPAR[ind_c3]) end;
    if isnan(ρ_nir_c3) ρ_nir_c3 = nanmean(CLM5_ρNIR[ind_c3]) end;
    if isnan(τ_nir_c3) τ_nir_c3 = nanmean(CLM5_τNIR[ind_c3]) end;

    ρ_par_c4 = CLM5_ρPAR[ind_c4];
    τ_par_c4 = CLM5_τPAR[ind_c4];
    ρ_nir_c4 = CLM5_ρNIR[ind_c4];
    τ_nir_c4 = CLM5_τNIR[ind_c4];

    gm_dict = Dict{String,Any}(
                "B6F"           => resample(vcmax .* 0.0066, "1D", dts.LABELS.year),
                "CANOPY_HEIGHT" => max(0.1, zc),
                "CHLOROPHYLL"   => resample(chls, "1D", dts.LABELS.year),
                "CLUMPING"      => resample(cis, "1D", dts.LABELS.year),
                "CO2"           => co2,
                "ELEVATION"     => dts.t_ele[ilon,ilat],
                "G1_MEDLYN_C3"  => g1_c3_medlyn,
                "G1_MEDLYN_C4"  => g1_c4_medlyn,
                "JMAX25"        => resample(vcmax .* 1.64, "1D", dts.LABELS.year),
                "LAI"           => resample(lais, "1D", dts.LABELS.year),
                "LAND_MASK"     => lmsk,
                "LATITUDE"      => (ilat - 0.5) * reso - 90,
                "LAT_INDEX"     => ilat,
                "LMA"           => lma,
                "LONGITUDE"     => (ilon - 0.5) * reso - 180,
                "LON_INDEX"     => ilon,
                "PFT_FRACTIONS" => pfts,
                "RESO_SPACE"    => dts.LABELS.nx,
                "SAI"           => nanmax(lais) / 10,
                "SOIL_COLOR"    => scolor,
                "SOIL_N"        => s_n,
                "SOIL_α"        => s_α,
                "SOIL_ΘR"       => s_Θr,
                "SOIL_ΘS"       => s_Θs,
                "VCMAX25"       => resample(vcmax, "1D", dts.LABELS.year),
                "YEAR"          => dts.LABELS.year,
                "ρ_NIR"         => ρ_nir,
                "ρ_NIR_C3"      => ρ_nir_c3,
                "ρ_NIR_C4"      => ρ_nir_c4,
                "ρ_PAR"         => ρ_par,
                "ρ_PAR_C3"      => ρ_par_c3,
                "ρ_PAR_C4"      => ρ_par_c4,
                "τ_NIR"         => τ_nir,
                "τ_NIR_C3"      => τ_nir_c3,
                "τ_NIR_C4"      => τ_nir_c4,
                "τ_PAR"         => τ_par,
                "τ_PAR_C3"      => τ_par_c3,
                "τ_PAR_C4"      => τ_par_c4);
    verification ? (@assert NaN_test(gm_dict) "gm_dict contains NaN values") : nothing;

    return gm_dict
);

grid_dict(dtl::LandDatasetLabels, lat::Number, lon::Number; verification::Bool = true) = (
    lmsk = read_dataset(dtl.tag_t_lm, lat, lon);
    if !(lmsk > 0)
        return error("The target grid does not contain land!");
    end;

    lais = read_dataset(dtl.tag_p_lai, lat, lon);
    if !(nanmax(lais) > 0)
        return error("The target grid is not vegetated!");
    end;

    co2 = CO₂_ppm(dtl.year, true);
    scolor = min(20, max(1, Int(floor(read_dataset(dtl.tag_s_cc, lat, lon)))));
    s_α = read_dataset(dtl.tag_s_α, lat, lon);
    s_n = read_dataset(dtl.tag_s_n, lat, lon);
    s_Θr = read_dataset(dtl.tag_s_Θr, lat, lon);
    s_Θs = read_dataset(dtl.tag_s_Θs, lat, lon);

    # else return the grid dictionary if the grid is masked as plant
    chls = read_dataset(dtl.tag_p_chl, lat, lon);
    cis = read_dataset(dtl.tag_p_ci, lat, lon);
    lma = 1 / read_dataset(dtl.tag_p_sla, lat, lon) / 10;
    pfts = read_dataset(dtl.tag_t_pft, lat, lon);
    zc = read_dataset(dtl.tag_p_ch, lat, lon);

    if dtl.gm_tag == "gm3"
        vcmax = read_dataset("VCMAX_2X_1Y_V2", lat, lon) .* 0.6;
    else
        vcmax = read_dataset(dtl.tag_p_vcm, lat, lon);
    end;

    # gap fill the data for seasonal trends
    gapfill_data!(chls);
    gapfill_data!(cis);
    gapfill_data!(lais);
    gapfill_data!(vcmax);

    # compute g1 for Medlyn model
    ind_c3 = [2:14;16;17];
    ind_c4 = 15;
    ind_plant = 2:17;

    g1_c3_medlyn = CLM5_PFTG[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    if isnan(g1_c3_medlyn) g1_c3_medlyn = nanmean(CLM5_PFTG[ind_c3]) end;
    g1_c4_medlyn = CLM5_PFTG[ind_c4];

    # broadband leaf optical properties
    ρ_par = CLM5_ρPAR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    τ_par = CLM5_τPAR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    ρ_nir = CLM5_ρNIR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    τ_nir = CLM5_τNIR[ind_plant]' * pfts[ind_plant] / sum(pfts[ind_plant]);
    if isnan(ρ_par) ρ_par = nanmean(CLM5_ρPAR[ind_plant]) end;
    if isnan(τ_par) τ_par = nanmean(CLM5_τPAR[ind_plant]) end;
    if isnan(ρ_nir) ρ_nir = nanmean(CLM5_ρNIR[ind_plant]) end;
    if isnan(τ_nir) τ_nir = nanmean(CLM5_τNIR[ind_plant]) end;

    ρ_par_c3 = CLM5_ρPAR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    τ_par_c3 = CLM5_τPAR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    ρ_nir_c3 = CLM5_ρNIR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    τ_nir_c3 = CLM5_τNIR[ind_c3]' * pfts[ind_c3] / sum(pfts[ind_c3]);
    if isnan(ρ_par_c3) ρ_par_c3 = nanmean(CLM5_ρPAR[ind_c3]) end;
    if isnan(τ_par_c3) τ_par_c3 = nanmean(CLM5_τPAR[ind_c3]) end;
    if isnan(ρ_nir_c3) ρ_nir_c3 = nanmean(CLM5_ρNIR[ind_c3]) end;
    if isnan(τ_nir_c3) τ_nir_c3 = nanmean(CLM5_τNIR[ind_c3]) end;

    ρ_par_c4 = CLM5_ρPAR[ind_c4];
    τ_par_c4 = CLM5_τPAR[ind_c4];
    ρ_nir_c4 = CLM5_ρNIR[ind_c4];
    τ_nir_c4 = CLM5_τNIR[ind_c4];

    gm_dict = Dict{String,Any}(
                "B6F"           => resample(vcmax .* 0.0066, "1D", dtl.year),
                "CANOPY_HEIGHT" => max(0.1, zc),
                "CHLOROPHYLL"   => resample(chls, "1D", dtl.year),
                "CLUMPING"      => resample(cis, "1D", dtl.year),
                "CO2"           => co2,
                "ELEVATION"     => read_dataset(dtl.tag_t_ele, lat, lon),
                "G1_MEDLYN_C3"  => g1_c3_medlyn,
                "G1_MEDLYN_C4"  => g1_c4_medlyn,
                "JMAX25"        => resample(vcmax .* 1.64, "1D", dtl.year),
                "LAI"           => resample(lais, "1D", dtl.year),
                "LAND_MASK"     => lmsk,
                "LATITUDE"      => lat,
                "LAT_INDEX"     => lat_ind(lat, 1/dtl.nx),
                "LMA"           => lma,
                "LONGITUDE"     => lon,
                "LON_INDEX"     => lon_ind(lon, 1/dtl.nx),
                "RESO_SPACE"    => dtl.nx,
                "PFT_FRACTIONS" => pfts,
                "SAI"           => nanmax(lais) / 10,
                "SOIL_COLOR"    => scolor,
                "SOIL_N"        => s_n,
                "SOIL_α"        => s_α,
                "SOIL_ΘR"       => s_Θr,
                "SOIL_ΘS"       => s_Θs,
                "VCMAX25"       => resample(vcmax, "1D", dtl.year),
                "YEAR"          => dtl.year,
                "ρ_NIR"         => ρ_nir,
                "ρ_NIR_C3"      => ρ_nir_c3,
                "ρ_NIR_C4"      => ρ_nir_c4,
                "ρ_PAR"         => ρ_par,
                "ρ_PAR_C3"      => ρ_par_c3,
                "ρ_PAR_C4"      => ρ_par_c4,
                "τ_NIR"         => τ_nir,
                "τ_NIR_C3"      => τ_nir_c3,
                "τ_NIR_C4"      => τ_nir_c4,
                "τ_PAR"         => τ_par,
                "τ_PAR_C3"      => τ_par_c3,
                "τ_PAR_C4"      => τ_par_c4);
    verification ? (@assert NaN_test(gm_dict) "gm_dict contains NaN values") : nothing;

    return gm_dict
);

grid_dict(gmt::String, year::Int, lat::Number, lon::Number; args...) = grid_dict(LandDatasetLabels(gmt, year), lat, lon; args...);
