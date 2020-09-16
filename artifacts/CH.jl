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




# Gridded per 0.05 degree per year? decade?
# Query the cht hash from Artifacts.toml, if not existing create one
cht_hash = artifact_hash("canopy_height_0_05_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(cht_hash) || !artifact_exists(cht_hash)
    println("No artifacts found for Canopy Height 0.05 deg, deploy it now...");

    cht_fold = joinpath(ftp_loc, "CH");

    cht_hash = create_artifact() do artifact_dir
        _file = "canopy_height_0_05_deg.nc";
        _path = joinpath(cht_fold, _file);
        cp(_path, joinpath(artifact_dir, _file));
    end
    @show cht_hash;

    tar_url  = "$(ftp_url)/CH/canopy_height_0_05_deg.tar.gz";
    tar_loc  = "$(ftp_loc)/CH/canopy_height_0_05_deg.tar.gz";
    tar_hash = archive_artifact(cht_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "canopy_height_0_05_deg", cht_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of Canopy Height 0.05 deg already exists, skip it");
end
