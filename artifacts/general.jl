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




# function to create artifact
"""
    deploy_artifact(files::Array{String,1},
                    art_name::String,
                    data_folder::String,
                    art_folder::String)

Deploy the artifact, given
- `files` Array of file names
- `art_name` Artifact identity
- `art_folder`
"""
function deploy_artifact(
            files::Array{String,1},
            art_name::String,
            art_folder::String,
            data_folder::String = joinpath(ftp_loc, art_folder)
)
    # querry whether the artifact exists
    art_hash = artifact_hash(art_name, artifact_toml);

    # create artifact
    if isnothing(art_hash) || !artifact_exists(art_hash)
        println("Artifact ", art_name, " not found, deploy it now...");

        art_hash = create_artifact() do artifact_dir
            for _file in files
                _path = joinpath(data_folder, _file);
                cp(_path, joinpath(artifact_dir, _file));
            end
        end
        @show art_hash;

        tar_url  = "$(ftp_url)/$(art_folder)/$(art_name).tar.gz";
        tar_loc  = "$(ftp_loc)/$(art_folder)/$(art_name).tar.gz";
        tar_hash = archive_artifact(art_hash, tar_loc);
        @show tar_hash;

        bind_artifact!(artifact_toml, art_name, art_hash;
                       download_info=[(tar_url, tar_hash)],
                       lazy=true,
                       force=true);
    else
        println("Artifact ", art_name, " already exists, skip it");
    end

    return nothing
end




# deploy artifacts
deploy_artifact(["Chl_Mean_2003-2011_Weekly_0.50deg.nc"],
                "leaf_chlorophyll_0_5_deg_7D",
                "Leaf")
