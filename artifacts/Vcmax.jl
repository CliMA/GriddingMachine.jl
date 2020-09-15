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




# Gridded per 0.2 degree per 8 day
# Query the vcm hash from Artifacts.toml, if not existing create one
vcm_hash = artifact_hash("vcmax_0_5_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(vcm_hash) || !artifact_exists(vcm_hash)
    println("No artifacts found for Vcmax 0.5 deg, deploy it now...");

    vcm_fold = joinpath(ftp_loc, "Vcmax");

    vcm_hash = create_artifact() do artifact_dir
        _file = "optimal_vcmax_globe.nc";
        _path = joinpath(vcm_fold, _file);
        cp(_path, joinpath(artifact_dir, _file));
    end
    @show vcm_hash;

    tar_url  = "$(ftp_url)/Vcmax/vcmax_0_5_deg.tar.gz";
    tar_loc  = "$(ftp_loc)/Vcmax/vcmax_0_5_deg.tar.gz";
    tar_hash = archive_artifact(vcm_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "vcmax_0_5_deg", vcm_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of Vcmax 0.5 deg already exists, skip it");
end
