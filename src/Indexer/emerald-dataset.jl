""" Structure to save gridded datasets from GriddingMachine for global simulations (labels only) """
Base.@kwdef mutable struct LandDatasetLabels
    "GriddingMachine datasets version"
    gm_tag::String
    "Which year do the datasets apply (when applicable)"
    year::Int
    "Spatial resolution zoom factor, resolution is 1/nx °"
    nx::Int
    "GriddingMachine.jl tag for soil color class"
    tag_s_cc::String
    "GriddingMachine.jl tag for soil van Genuchten parameters"
    tag_s_α::String
    "GriddingMachine.jl tag for soil van Genuchten parameters"
    tag_s_n::String
    "GriddingMachine.jl tag for soil van Genuchten parameters"
    tag_s_Θr::String
    "GriddingMachine.jl tag for soil van Genuchten parameters"
    tag_s_Θs::String
    "GriddingMachine.jl tag for canopy height"
    tag_p_ch::String
    "GriddingMachine.jl tag for chlorophyll content"
    tag_p_chl::String
    "GriddingMachine.jl tag for clumping index"
    tag_p_ci::String
    "GriddingMachine.jl tag for leaf area index"
    tag_p_lai::String
    "GriddingMachine.jl tag for specific leaf area"
    tag_p_sla::String
    "GriddingMachine.jl tag for Vcmax"
    tag_p_vcm::String
    "GriddingMachine.jl tag for elevation"
    tag_t_ele::String
    "GriddingMachine.jl tag for land mask"
    tag_t_lm::String
    "GriddingMachine.jl tag for PFT"
    tag_t_pft::String
end;

"""

    LandDatasetLabels(gm_tag::String, year::Int)

Constructor of LandDatasetLabels, given
- `gm_tag` version of GriddingMachine datasets collection
- `year` year of the datasets

"""
LandDatasetLabels(gm_tag::String, year::Int) = (
    @assert gm_tag in ["gm1", "gm2"] "Parameterization tag $(gm_tag) is not supported!";

    if gm_tag == "gm1"
        dtl = LandDatasetLabels(
                    gm_tag    = gm_tag,
                    year      = year,
                    nx        = 1,
                    tag_s_cc  = "SC_2X_1Y_V1",
                    tag_s_α   = "SOIL_VGA_12X_1Y_V1",
                    tag_s_n   = "SOIL_VGN_12X_1Y_V1",
                    tag_s_Θr  = "SOIL_SWCR_12X_1Y_V1",
                    tag_s_Θs  = "SOIL_SWCS_12X_1Y_V1",
                    tag_p_ch  = "CH_20X_1Y_V1",
                    tag_p_chl = "CHL_2X_7D_V1",
                    tag_p_ci  = "CI_2X_1Y_V1",
                    tag_p_lai = "LAI_MODIS_2X_8D_$(year)_V1",
                    tag_p_sla = "SLA_2X_1Y_V1",
                    tag_p_vcm = "VCMAX_2X_1Y_V2",
                    tag_t_ele = "ELEV_4X_1Y_V1",
                    tag_t_lm  = "LM_4X_1Y_V1",
                    tag_t_pft = "PFT_2X_1Y_V1")
    elseif gm_tag == "gm2"
        dtl = LandDatasetLabels(
                    gm_tag    = gm_tag,
                    year      = year,
                    nx        = 1,
                    tag_s_cc  = "SC_2X_1Y_V1",
                    tag_s_α   = "SOIL_VGA_12X_1Y_V1",
                    tag_s_n   = "SOIL_VGN_12X_1Y_V1",
                    tag_s_Θr  = "SOIL_SWCR_12X_1Y_V1",
                    tag_s_Θs  = "SOIL_SWCS_12X_1Y_V1",
                    tag_p_ch  = "CH_20X_1Y_V1",
                    tag_p_chl = "CHL_2X_7D_V1",
                    tag_p_ci  = "CI_2X_1M_V3",
                    tag_p_lai = "LAI_MODIS_2X_8D_$(year)_V1",
                    tag_p_sla = "SLA_2X_1Y_V1",
                    tag_p_vcm = "VCMAX_2X_1Y_V2",
                    tag_t_ele = "ELEV_4X_1Y_V1",
                    tag_t_lm  = "LM_4X_1Y_V1",
                    tag_t_pft = "PFT_2X_1Y_V1")
    else
        error("Tag $(gm_tag) is not supported!");
    end;

    return dtl
);


""" Structure to save gridded datasets from GriddingMachine for global simulations """
Base.@kwdef mutable struct LandDatasets{FT<:AbstractFloat}
    # labels for the datasets
    "Land dataset labels"
    LABELS::LandDatasetLabels

    # soil properties
    "Soil color class"
    s_cc::Array{FT} = regrid(read_dataset(LABELS.tag_s_cc), LABELS.nx);
    "Soil van Genuchten α"
    s_α::Array{FT} = regrid(read_dataset(LABELS.tag_s_α), LABELS.nx)
    "Soil van Genuchten n"
    s_n::Array{FT} = regrid(read_dataset(LABELS.tag_s_n), LABELS.nx)
    "Soil van Genuchten Θr"
    s_Θr::Array{FT} = regrid(read_dataset(LABELS.tag_s_Θr), LABELS.nx)
    "Soil van Genuchten Θs"
    s_Θs::Array{FT} = regrid(read_dataset(LABELS.tag_s_Θs), LABELS.nx)

    # plant properties
    "Plant canopy height"
    p_ch::Array{FT} = regrid(read_dataset(LABELS.tag_p_ch), LABELS.nx)
    "Plant chlorophyll content"
    p_chl::Array{FT} = regrid(read_dataset(LABELS.tag_p_chl), LABELS.nx)
    "Stand clumping index"
    p_ci::Array{FT} = regrid(read_dataset(LABELS.tag_p_ci), LABELS.nx)
    "Stand leaf area index"
    p_lai::Array{FT} = regrid(read_dataset(LABELS.tag_p_lai), LABELS.nx)
    "Plant leaf specific area"
    p_sla::Array{FT} = regrid(read_dataset(LABELS.tag_p_sla), LABELS.nx)
    "Plant maximum carboxylation rate"
    p_vcm::Array{FT} = regrid(read_dataset(LABELS.tag_p_vcm), LABELS.nx)

    # stand properties
    "Stand elevation"
    t_ele::Array{FT} = regrid(read_dataset(LABELS.tag_t_ele), LABELS.nx)
    "Stand land mask"
    t_lm::Array{FT} = regrid(read_dataset(LABELS.tag_t_lm), LABELS.nx)
    "Stand PFT percentages `[%]`"
    t_pft::Array{FT} = regrid(read_dataset(LABELS.tag_t_pft), LABELS.nx)
    # masks
    "Mask for bare soil"
    mask_soil::Matrix{Bool} = zeros(Bool, size(t_lm))
    "Mask for SPAC"
    mask_spac::Matrix{Bool} = zeros(Bool, size(t_lm))
end;

"""

    LandDatasets{FT}(gm_tag::String, year::Int) where {FT}

Constructor of LandDatasets, given
- `gm_tag` Unique tag of GriddingMachine parameterization
- `year` year of simulations

"""
LandDatasets{FT}(gm_tag::String, year::Int; msg_level::String = "tinfo") where {FT} = (
    dtl = LandDatasetLabels(gm_tag, year);

    pretty_display!("Querying data from GriddingMachine...", msg_level);
    dts = LandDatasets{FT}(LABELS = dtl);

    pretty_display!("Gap-filling data from GriddingMachine...", msg_level);
    extend_data!(dts);

    return dts
);


"""

    extend_data!(dts::LandDatasets{FT}) where {FT}

Gap fill the data linearly, given
- `dts` LandDatasets struct

"""
function extend_data!(dts::LandDatasets{FT}) where {FT}
    # determine where to fill based on land mask and lai
    for ilon in axes(dts.t_lm,1), ilat in axes(dts.t_lm,2)
        if (dts.t_lm[ilon,ilat] > 0) && (nanmax(dts.p_lai[ilon,ilat,:]) > 0)
            dts.mask_spac[ilon,ilat] = true;
            mask_lai = isnan.(dts.p_lai[ilon,ilat,:]);
            @. dts.p_lai[ilon,ilat,mask_lai] = 0;
        elseif (dts.t_lm[ilon,ilat] > 0)
            dts.mask_soil[ilon,ilat] = true;
            mask_lai = isnan.(dts.p_lai[ilon,ilat,:]);
            @. dts.p_lai[ilon,ilat,mask_lai] = 0;
        end;
    end;

    # iterate the fieldnames
    for fn in fieldnames(typeof(dts))
        if !(fn in [:p_lai, :t_ele, :t_lm, :t_pft, :mask_soil, :mask_spac])
            data = getfield(dts, fn);
            if data isa Array
                # extend the data first based on interpolations
                for ilon in axes(dts.t_lm,1), ilat in axes(dts.t_lm,2)
                    tmp = data[ilon,ilat,:];
                    gapfill_data!(tmp);
                    @. data[ilon,ilat,:] = tmp;
                end;

                # fill the NaNs with nanmean of the rest for vegetated grids (2D or 3D does not matter)
                if fn in [:p_ch, :p_chl, :p_ci, :p_sla, :p_vcm]
                    mask_mean = dts.mask_spac .&& isnan.(data);
                    data_mean = nanmean(data);
                    @. data[mask_mean] = data_mean;
                end;

                # fill the NaNs with Loam soil for both vegetated and bare soil grids
                if fn in [:s_α, :s_n, :s_Θr, :s_Θs]
                    mask_mean = (dts.mask_spac .|| dts.mask_soil) .&& isnan.(data);
                    if fn == :s_α
                        @. data[mask_mean] = 367.3476;
                    elseif fn == :s_n
                        @. data[mask_mean] = 1.56;
                    elseif fn == :s_Θr
                        @. data[mask_mean] = 0.078;
                    elseif fn == :s_Θs
                        @. data[mask_mean] = 0.43;
                    end;
                end;
            end;
        end;
    end;

    return nothing
end;
