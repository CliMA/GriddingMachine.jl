###############################################################################
#
# Download the artifacts manually to avoid slow downloading from julia server
#
###############################################################################
GRIDDINGMACHINE_ARTIFACTS = joinpath(@__DIR__, "../../Artifacts.toml");




"""
    predownload_artifact(
                name::String,
                artifact_toml::String = GRIDDINGMACHINE_ARTIFACTS)

Download the artifact from given server if it does not exist, given
- `name` Artifact name
- `artifact_toml` Artifacts.toml file location
"""
function predownload_artifact(
            name::String,
            artifact_toml::String = GRIDDINGMACHINE_ARTIFACTS
)
    meta = artifact_meta(name, artifact_toml);
    hash = Base.SHA1(meta["git-tree-sha1"]);

    # try to download the artifact from all entries if it does not exist
    if !artifact_exists(hash)
        for entry in meta["download"]
            url              = entry["url"];
            tarball_hash     = entry["sha256"];
            download_success = download_artifact(hash, url, tarball_hash);
            if download_success
                break
            end
        end
    end

    return nothing
end
