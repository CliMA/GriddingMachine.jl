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
# Query the leaf hash from Artifacts.toml, if not existing create one
leaf_hash = artifact_hash("leaf_sla_n_p_0_5_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(leaf_hash) || !artifact_exists(leaf_hash)
    println("No artifacts found for Leaf 0.5 deg, deploy it now...");

    leaf_fold = joinpath(ftp_loc, "Leaf");

    leaf_hash = create_artifact() do artifact_dir
        _files = ["leaf_sla.nc", "leaf_nitrogen.nc", "leaf_phosphorus.nc"];
        for _file in _files
            _path = joinpath(leaf_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show leaf_hash;

    tar_url  = "$(ftp_url)/Leaf/leaf_sla_n_p_0_5_deg.tar.gz";
    tar_loc  = "$(ftp_loc)/Leaf/leaf_sla_n_p_0_5_deg.tar.gz";
    tar_hash = archive_artifact(leaf_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "leaf_sla_n_p_0_5_deg", leaf_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of Leaf 0.5 deg already exists, skip it");
end
