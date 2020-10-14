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




# Gridded per 0.5 degree per year? decade?
# Query the NPP hash from Artifacts.toml, if not existing create one
npp_hash = artifact_hash("npp_1_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(npp_hash) || !artifact_exists(npp_hash)
    println("No artifacts found for NPP 1 deg, deploy it now...");

    npp_fold = joinpath(ftp_loc, "NPP");

    npp_hash = create_artifact() do artifact_dir
        _files = ["npp_modis_2000.nc"];
        for _file in _files
            _path = joinpath(npp_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show npp_hash;

    tar_url  = "$(ftp_url)/NPP/npp_1_deg.tar.gz";
    tar_loc  = "$(ftp_loc)/NPP/npp_1_deg.tar.gz";
    tar_hash = archive_artifact(npp_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "npp_1_deg", npp_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of NPP 1 deg already exists, skip it");
end
