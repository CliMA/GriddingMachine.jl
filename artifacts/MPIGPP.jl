###############################################################################
#
# Run this file on the FTP server to set up Artifacts
# TODO filter out GPP from the original file
#
###############################################################################
using Pkg.Artifacts




# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../Artifacts.toml");




# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";
ftp_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT";




# Gridded per 0.5 degree per 8 day
# Query the MPI hash from Artifacts.toml, if not existing create one
mpi_hash = artifact_hash("MPI_GPP_v006_0_5_deg_8D", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(mpi_hash) || !artifact_exists(mpi_hash)
    println("No artifacts found for MPI GPP 0.5 deg, deploy it now...");

    mpi_fold = "/net/fluo/data2/data/MPI-FLUXCOM-GPP-NEE-TER/original/720_360/8daily";

    mpi_hash = create_artifact() do artifact_dir
        for year in 2001:2019
            _file = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.8daily." *
                    string(year) * ".nc";
            _path = joinpath(mpi_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show mpi_hash;

    tar_url  = "$(ftp_url)/GPP/MPI_GPP_v006_0_5_deg_8D_2001_2019.tar.gz";
    tar_loc  = "$(ftp_loc)/GPP/MPI_GPP_v006_0_5_deg_8D_2001_2019.tar.gz";
    tar_hash = archive_artifact(mpi_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "MPI_GPP_v006_0_5_deg_8D", mpi_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of MPI GPP 0.5 deg already exists, skip it");
end




# Gridded per 0.5 degree per month
# Query the MPI hash from Artifacts.toml, if not existing create one
mpi_hash = artifact_hash("MPI_GPP_v006_0_5_deg_1M", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(mpi_hash) || !artifact_exists(mpi_hash)
    println("No artifacts found for MPI GPP 0.5 deg, deploy it now...");

    mpi_fold = "/net/fluo/data2/data/MPI-FLUXCOM-GPP-NEE-TER/original/720_360/monthly";

    mpi_hash = create_artifact() do artifact_dir
        for year in 2001:2019
            _file = "GPP.RS_V006.FP-ALL.MLM-ALL.METEO-NONE.720_360.monthly." *
                    string(year) * ".nc";
            _path = joinpath(mpi_fold, _file);
            cp(_path, joinpath(artifact_dir, _file));
        end
    end
    @show mpi_hash;

    tar_url  = "$(ftp_url)/GPP/MPI_GPP_v006_0_5_deg_1M_2001_2019.tar.gz";
    tar_loc  = "$(ftp_loc)/GPP/MPI_GPP_v006_0_5_deg_1M_2001_2019.tar.gz";
    tar_hash = archive_artifact(mpi_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "MPI_GPP_v006_0_5_deg_1M", mpi_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of MPI GPP 0.5 deg already exists, skip it");
end
