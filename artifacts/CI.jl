###############################################################################
#
# Run this file on the FTP server to set up Clumping Index Artifacts
#
###############################################################################
using ArchGDAL
using Pkg.Artifacts




# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../Artifacts.toml");




# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";
ftp_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT";




# Gridded per 500 m (0.00417 deg) per year? decade?
# Query the cli hash from Artifacts.toml, if not existing create one
cli_hash = artifact_hash("clumping_index_500_m", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(cli_hash) || !artifact_exists(cli_hash)
    println("No artifacts found for Clumping Index 500 m, deploy it now...");

    cli_fold = joinpath(ftp_loc, "CI");

    cli_hash = create_artifact() do artifact_dir
        _file = "global_clumping_index.tif";
        _path = joinpath(cli_fold, _file);
        cp(_path, joinpath(artifact_dir, _file));
    end
    @show cli_hash;

    tar_url  = "$(ftp_url)/CI/clumping_index_500_m.tar.gz";
    tar_loc  = "$(ftp_loc)/CI/clumping_index_500_m.tar.gz";
    tar_hash = archive_artifact(cli_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "clumping_index_500_m", cli_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of Canopy Height 500 m already exists, skip it");
end




# Gridded per 0.5 deg per year? decade?
# Query the cli hash from Artifacts.toml, if not existing create one
cli_hash = artifact_hash("clumping_index_0_5_deg_PFT", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(cli_hash) || !artifact_exists(cli_hash)
    println("No artifacts found for Clumping Index 0.5 deg, deploy it now...");

    cli_fold = joinpath(ftp_loc, "CI");

    cli_hash = create_artifact() do artifact_dir
        _file = "clumping_factor_pft.nc";
        _path = joinpath(cli_fold, _file);
        cp(_path, joinpath(artifact_dir, _file));
    end
    @show cli_hash;

    tar_url  = "$(ftp_url)/CI/clumping_index_0_5_deg_PFT.tar.gz";
    tar_loc  = "$(ftp_loc)/CI/clumping_index_0_5_deg_PFT.tar.gz";
    tar_hash = archive_artifact(cli_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "clumping_index_0_5_deg_PFT", cli_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of Canopy Height 0.5 deg already exists, skip it");
end
