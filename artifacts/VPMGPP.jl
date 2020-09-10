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




# Gridded per 0.2 degree
# Query the VPM hash from Artifacts.toml, if not existing create one
vpm_hash = artifact_hash("VPM_GPP_v20_0_2_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(vpm_hash) || !artifact_exists(vpm_hash)
    println("No artifacts found for VPM GPP 0.2 deg, deploy it now...");

    vpm_fold = "/net/fluo/data2/data/VPM-GPP/original/0.20-degree";

    vpm_hash = create_artifact() do artifact_dir
        for year in 2000:2019
            _file = "GPP.VPM.v20." * string(year) * ".8-day.0.20_deg.nc";
            _path = joinpath(vpm_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show vpm_hash;

    tar_url  = "$(ftp_url)/GPP/VPM_GPP_v20_0_2_deg_2000_2019.tar.gz";
    tar_loc  = "$(ftp_loc)/GPP/VPM_GPP_v20_0_2_deg_2000_2019.tar.gz";
    tar_hash = archive_artifact(vpm_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "VPM_GPP_v20_0_2_deg", vpm_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of VPM GPP 0.2 deg already exists, skip it");
end




# Gridded per 0.083 degree
# Query the VPM hash from Artifacts.toml, if not existing create one
vpm_hash = artifact_hash("VPM_GPP_v20_0_083_deg", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(vpm_hash) || !artifact_exists(vpm_hash)
    println("No artifacts found for VPM GPP 0.083 deg, deploy it now...");

    vpm_fold = "/net/fluo/data2/data/VPM-GPP/original/0.083-degree";

    vpm_hash = create_artifact() do artifact_dir
        for year in 2000:2019
            _file = "GPP.VPM.v20." * string(year) * ".8-day.0.083_deg.nc";
            _path = joinpath(vpm_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show vpm_hash;

    tar_url  = "$(ftp_url)/GPP/VPM_GPP_v20_0_083_deg_2000_2019.tar.gz";
    tar_loc  = "$(ftp_loc)/GPP/VPM_GPP_v20_0_083_deg_2000_2019.tar.gz";
    tar_hash = archive_artifact(vpm_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "VPM_GPP_v20_0_083_deg", vpm_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of VPM GPP 0.083 already exists, skip it");
end
