###############################################################################
#
# Create and deploy artifacts
#
###############################################################################
# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../../Artifacts.toml");

# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";

# Query the LAI hash from Artifacts.toml, if not existing create one
lai_hash = artifact_hash("lai_monthly_mean", artifact_toml);
if isnothing(lai_hash) || !artifact_exists(lai_hash)
    lai_url  = "$(ftp_url)/LAI/LAI_mean_monthly_1981-2015.nc4";
    lai_hash = create_artifact() do artifact_dir
        download(lai_url, joinpath(artifact_dir, "lai_monthly_mean.nc4"));
    end
    tar_url  = "$(ftp_url)/LAI/LAI_mean_monthly_1981-2015.tar.gz";
    tar_hash = archive_artifact(lai_hash, "LAI_mean_monthly_1981-2015.tar.gz");
    bind_artifact!(artifact_toml, "lai_monthly_mean", lai_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
end
