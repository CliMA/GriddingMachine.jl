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




# Model --- land model spectrums
deploy_artifact(artifact_toml,
                "land_model_spectrum",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LandModel",
                ["Optipar2017_ProspectD.mat", "sun.mat"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LandModel",
                [ftp_url*"LandModel", git_url]);




# Stand --- net primary productivity
deploy_artifact(artifact_toml,
                "NPP_MODIS_1X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/NPP",
                ["npp_modis_1X_1Y_2000.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/NPP",
                [ftp_url*"/NPP", git_url]);




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




# Surface --- surface data
deploy_artifact(artifact_toml,
                "surface_data_2X_1Y",
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                ["surface_data_2X_1Y.nc"],
                "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/LM",
                [ftp_url*"/LM", git_url]);
