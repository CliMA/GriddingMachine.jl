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

# Query the LAI hash from Artifacts.toml, if not existing create one
lai_hash = artifact_hash("lai_monthly_mean", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(lai_hash) || !artifact_exists(lai_hash)
    println("No artifacts found for LAI, deploy it now...");

    lai_url  = "$(ftp_url)/LAI/LAI_mean_monthly_1981-2015.nc4";
    lai_hash = create_artifact() do artifact_dir
        download(lai_url, joinpath(artifact_dir, "lai_monthly_mean.nc4"));
    end
    @show lai_hash;

    tar_url  = "$(ftp_url)/LAI/LAI_mean_monthly_1981-2015.tar.gz";
    tar_loc  = "$(ftp_loc)/LAI/LAI_mean_monthly_1981-2015.tar.gz";
    tar_hash = archive_artifact(lai_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "lai_monthly_mean", lai_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of LAI already exists, skip it");
end
