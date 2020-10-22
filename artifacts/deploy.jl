###############################################################################
#
# Run this file on the FTP server to set up Artifacts
#
###############################################################################
using Pkg.Artifacts




# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../Artifacts.toml");




# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";
ftp_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT";
git_url = "https://github.com/Yujie-W/ResearchArtifacts/raw/wyujie/CliMA_LUT"




# function to create artifact
"""
    deploy_artifact(files::Array{String,1},
                    art_name::String,
                    data_folder::String,
                    art_folder::String,
                    new_files::Array{String,1})

Deploy the artifact, given
- `files` Array of file names
- `art_name` Artifact identity
- `art_folder` Artifact folder name on FTP
- `data_folder` Optional. Path to original files
- `new_files` Optional. New file names
"""
function deploy_artifact(
            files::Array{String,1},
            art_name::String,
            art_folder::String,
            data_folder::String = joinpath(ftp_loc, art_folder),
            new_files::Array{String,1} = files;
            git_copy::Bool = true
)
    # querry whether the artifact exists
    art_hash = artifact_hash(art_name, artifact_toml);

    # create artifact
    if isnothing(art_hash) || !artifact_exists(art_hash)
        println("\nArtifact ", art_name, " not found, deploy it now...");

        art_hash = create_artifact() do artifact_dir
            for i in eachindex(files)
                _in   = files[i];
                _out  = new_files[i];
                _path = joinpath(data_folder, _in);
                println("Copying file ", _in);
                cp(_path, joinpath(artifact_dir, _out));
            end
        end
        @show art_hash;

        tar_ftp  = "$(ftp_url)/$(art_folder)/$(art_name).tar.gz";
        tar_git  = "$(git_url)/$(art_name).tar.gz";
        tar_loc  = "$(ftp_loc)/$(art_folder)/$(art_name).tar.gz";
        println("Compressing artifact...");
        tar_hash = archive_artifact(art_hash, tar_loc);
        @show tar_hash;

        if git_copy
            download_info = [(tar_ftp, tar_hash),(tar_git, tar_hash)];
        else
            download_info = [(tar_ftp, tar_hash)];
        end
        bind_artifact!(artifact_toml, art_name, art_hash;
                       download_info=download_info,
                       lazy=true,
                       force=true);
    else
        println("\nArtifact ", art_name, " already exists, skip it");
    end

    return nothing
end




# Leaf --- leaf chlorophyll
deploy_artifact(["leaf_chlorophyll_2X_7D.nc"],
                "leaf_chlorophyll_2X_7D",
                "Leaf");

# Leaf --- leaf traits
deploy_artifact(["leaf_nitrogen_2X_1Y.nc",
                 "leaf_phosphorus_2X_1Y.nc",
                 "specific_leaf_area_2X_1Y.nc",
                 "vcmax_optimal_cica_2X_1Y.nc"],
                "leaf_traits_2X_1Y",
                "Leaf");

# Canopy --- canopy height
deploy_artifact(["canopy_height_20X_1Y.nc"],
                "canopy_height_20X_1Y",
                "CH");

# Canopy --- clumping index
deploy_artifact(["global_clumping_index_2X_PFT.nc"],
                "clumping_index_2X_1Y_PFT",
                "CI")
deploy_artifact(["global_clumping_index_12X_WGS84.tif"],
                "clumping_index_12X_1Y",
                "CI");
deploy_artifact(["global_clumping_index_240X_WGS84.tif"],
                "clumping_index_240X_1Y",
                "CI"; git_copy=false);

# Canopy --- leaf area index
deploy_artifact(["leaf_area_index_4X_1M.nc"],
                "leaf_area_index_4X_1M",
                "LAI");

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
deploy_artifact(mpi_gpps_1X, "GPP_MPI_v006_1X_8D", "GPP/regridded");
deploy_artifact(mpi_gpps_8D, "GPP_MPI_v006_2X_8D", "GPP", mpi_fold_8D, out_gpps_8D; git_copy=false);
deploy_artifact(mpi_gpps_1M, "GPP_MPI_v006_2X_1M", "GPP", mpi_fold_1M, out_gpps_1M; git_copy=false);

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
deploy_artifact(vpm_gpps_1X, "GPP_VPM_v20_1X_8D" , "GPP/regridded");
deploy_artifact(vpm_gpps_5X, "GPP_VPM_v20_5X_8D" , "GPP", vpm_fold_5X, out_gpps_5X; git_copy=false);
deploy_artifact(vpm_gpps_12, "GPP_VPM_v20_12X_8D", "GPP", vpm_fold_12, out_gpps_12; git_copy=false);

# Stand --- land mask
deploy_artifact(["land_mask_ERA5_4X_1Y.nc"],
                "land_mask_ERA5_4X_1Y",
                "LM");
deploy_artifact(["land_mask_MODIS_12X_1Y.nc"],
                "land_mask_MODIS_12X_1Y",
                "LM");

# Stand --- net primary productivity
deploy_artifact(["npp_modis_1X_1Y_2000.nc"],
                "NPP_MODIS_1X_1Y",
                "NPP");

# Stand --- tree density
deploy_artifact(["tree_density_120X_1Y_WGS84.tif"],
                "tree_density_120X_1Y",
                "TD"; git_copy=false);
deploy_artifact(["tree_density_12X_1Y_WGS84.tif"],
                "tree_density_12X_1Y",
                "TD");

# Tools --- MODIS grid information
deploy_artifact(["MODIS_1km_grid.nc"],
                "MODIS_1km_grid",
                "MODIS"; git_copy=false);
deploy_artifact(["MODIS_500m_grid.nc"],
                "MODIS_500m_grid",
                "MODIS"; git_copy=false);
