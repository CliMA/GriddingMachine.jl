###############################################################################
#
# Run this file on the FTP server to set up Artifacts
#
###############################################################################
using Pkg.Artifacts
using PkgUtility




# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../Artifacts.toml");




# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";
ftp_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT";
git_url = "https://github.com/Yujie-W/ResearchArtifacts/raw/wyujie/CliMA_LUT"




# Leaf --- leaf chlorophyll
deploy_artifact(artifact_toml,
                "leaf_chlorophyll_2X_7D",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/Leaf",
                ["leaf_chlorophyll_2X_7D.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/Leaf",
                [ftp_url*"/Leaf", git_url]);

# Leaf --- leaf traits
deploy_artifact(artifact_toml,
                "leaf_traits_2X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/Leaf",
                ["leaf_nitrogen_2X_1Y.nc", "leaf_phosphorus_2X_1Y.nc",
                 "specific_leaf_area_2X_1Y.nc", "vcmax_optimal_cica_2X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/Leaf",
                [ftp_url*"/Leaf", git_url]);

# Canopy --- canopy height
deploy_artifact(artifact_toml,
                "canopy_height_20X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CH",
                ["canopy_height_20X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CH",
                [ftp_url*"/CH", git_url]);

# Canopy --- clumping index
deploy_artifact(artifact_toml,
                "clumping_index_2X_1Y_PFT",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                ["global_clumping_index_2X_PFT.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                [ftp_url*"/CI", git_url]);
deploy_artifact(artifact_toml,
                "clumping_index_12X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                ["global_clumping_index_12X_WGS84.tif"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                [ftp_url*"/CI", git_url]);
deploy_artifact(artifact_toml,
                "clumping_index_240X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                ["global_clumping_index_240X_WGS84.tif"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/CI",
                [ftp_url*"/CI"]);

# Canopy --- leaf area index
deploy_artifact(artifact_toml,
                "leaf_area_index_4X_1M",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LAI",
                ["leaf_area_index_4X_1M.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LAI",
                [ftp_url*"/LAI", git_url]);

# Model --- land model spectrums
deploy_artifact(artifact_toml,
                "land_model_spectrum",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LandModel",
                ["Optipar2017_ProspectD.mat", "sun.mat"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LandModel",
                [ftp_url*"LandModel", git_url]);

# Stand --- gross primary productivity
mpi_fold_8D = "/net/fluo/data2/data/MPI-FLUXCOM-GPP-NEE-TER/original/720_360/8daily";
mpi_fold_1M = "/net/fluo/data2/data/MPI-FLUXCOM-GPP-NEE-TER/original/720_360/monthly";
mpi_gpps_1X = String[];
mpi_gpps_8D = String[];
out_gpps_8D = String[];
mpi_gpps_1M = String[];
out_gpps_1M = String[];
for year in 2001:2019
    _in_1X  = "GPP_MPI_v006_1X_8D_" * string(year) * ".nc";
    push!(mpi_gpps_1X, _in_1X );
    _in_8D  = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.8daily." *
              string(year) * ".nc";
    _out_8D = "GPP_MPI_v006_2X_8D_" * string(year) * ".nc";
    push!(mpi_gpps_8D, _in_8D );
    push!(out_gpps_8D, _out_8D);
    _in_1M  = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.monthly." *
              string(year) * ".nc";
    _out_1M = "GPP_MPI_v006_2X_1M_" * string(year) * ".nc";
    push!(mpi_gpps_1M, _in_1M );
    push!(out_gpps_1M, _out_1M);
end
deploy_artifact(artifact_toml,
                "GPP_MPI_v006_1X_8D",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP/regridded",
                mpi_gpps_1X,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP/regridded",
                [ftp_url*"/GPP/regridded", git_url]);
deploy_artifact(artifact_toml,
                "GPP_MPI_v006_2X_8D",
                mpi_fold_8D,
                mpi_gpps_8D,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP",
                [ftp_url*"/GPP"];
                new_file = out_gpps_8D);
deploy_artifact(artifact_toml,
                "GPP_MPI_v006_2X_1M",
                mpi_fold_1M,
                mpi_gpps_1M,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP",
                [ftp_url*"/GPP"];
                new_file = out_gpps_1M);

vpm_fold_5X = "/net/fluo/data2/data/VPM-GPP/original/0.20-degree";
vpm_fold_12 = "/net/fluo/data2/data/VPM-GPP/original/0.083-degree";
vpm_gpps_1X = String[];
vpm_gpps_5X = String[];
out_gpps_5X = String[];
vpm_gpps_12 = String[];
out_gpps_12 = String[];
for year in 2000:2019
    _in_1X  = "GPP_VPM_v20_1X_8D_" * string(year) * ".nc";
    push!(vpm_gpps_1X, _in_1X );
    _in_5X  = "GPP.VPM.v20." * string(year) * ".8-day.0.20_deg.nc";
    _out_5X = "GPP_VPM_v20_5X_8D_" * string(year) * ".nc";
    push!(vpm_gpps_5X, _in_5X );
    push!(out_gpps_5X, _out_5X);
    _in_12  = "GPP.VPM.v20." * string(year) * ".8-day.0.083_deg.nc";
    _out_12 = "GPP_VPM_v20_12X_8D_" * string(year) * ".nc";
    push!(vpm_gpps_12, _in_12 );
    push!(out_gpps_12, _out_12);
end
deploy_artifact(artifact_toml,
                "GPP_VPM_v20_1X_8D",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP/regridded",
                vpm_gpps_1X,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP/regridded",
                [ftp_url*"/GPP/regridded", git_url]);
deploy_artifact(artifact_toml,
                "GPP_VPM_v20_5X_8D",
                vpm_fold_5X,
                vpm_gpps_5X,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP",
                [ftp_url*"/GPP"];
                new_file = out_gpps_5X);
deploy_artifact(artifact_toml,
                "GPP_VPM_v20_12X_8D",
                vpm_fold_12,
                vpm_gpps_12,
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP",
                [ftp_url*"/GPP"];
                new_file = out_gpps_12);

# Stand --- net primary productivity
deploy_artifact(artifact_toml,
                "NPP_MODIS_1X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/NPP",
                ["npp_modis_1X_1Y_2000.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/NPP",
                [ftp_url*"/NPP", git_url]);

# Stand --- sun induced fluorescence
deploy_artifact(artifact_toml,
                "SIF_TROPOMI_740_12X_8D",
                "/net/fluo/data2/data/TROPOMI_SIF740nm/reprocessed/0.0833_lat-lon_8d/global",
                ["TROPOMI_SIF740nm-v1.00833deg_regrid.8d.2018.nc",
                 "TROPOMI_SIF740nm-v1.00833deg_regrid.8d.2019.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/SIF",
                [ftp_url*"/SIF"];
                new_file=["SIF_TROPOMI_740_12X_8D_2018.nc",
                          "SIF_TROPOMI_740_12X_8D_2019.nc"]);
deploy_artifact(artifact_toml,
                "SIF_TROPOMI_740_1X_1M",
                "/net/fluo/data2/data/TROPOMI_SIF740nm/reprocessed/1deg_lat-lon_1M/global",
                ["TROPOMI_SIF740nm-v1.1deg_regrid.1d.2018.nc",
                 "TROPOMI_SIF740nm-v1.1deg_regrid.1d.2019.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/SIF",
                [ftp_url*"/SIF", git_url];
                new_file=["SIF_TROPOMI_740_1X_1M_2018.nc",
                          "SIF_TROPOMI_740_1X_1M_2019.nc"]);

# Stand --- tree density
deploy_artifact(artifact_toml,
                "tree_density_120X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/TD",
                ["tree_density_120X_1Y_WGS84.tif"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/TD",
                [ftp_url*"/TD"]);
deploy_artifact(artifact_toml,
                "tree_density_12X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/TD",
                ["tree_density_12X_1Y_WGS84.tif"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/TD",
                [ftp_url*"/TD", git_url]);

# Tools --- MODIS grid information
deploy_artifact(artifact_toml,
                "MODIS_1km_grid",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/MODIS",
                ["MODIS_1km_grid.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/MODIS",
                [ftp_url*"/MODIS"]);
deploy_artifact(artifact_toml,
                "MODIS_500m_grid",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/MODIS",
                ["MODIS_500m_grid.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/MODIS",
                [ftp_url*"/MODIS"]);

# Surface --- land mask
deploy_artifact(artifact_toml,
                "land_mask_ERA5_4X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                ["land_mask_ERA5_4X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                [ftp_url*"/LM", git_url]);

# Surface --- river
deploy_artifact(artifact_toml,
                "river_maps_4X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                ["river_maps_4X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                [ftp_url*"/LM", git_url]);

# Surface --- surface data
deploy_artifact(artifact_toml,
                "surface_data_2X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                ["surface_data_2X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                [ftp_url*"/LM", git_url]);
