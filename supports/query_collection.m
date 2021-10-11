% function to download and unpack the artifacts
function art_path = query_collection(art_name)
    % define paths
    if ispc
        HOME = [getenv('HOMEDRIVE'),getenv('HOMEPATH')];
    else
        HOME = getenv('HOME');
    end
    GM_DIR  = [HOME, '/GMCollections'];
    GM_TOML = [GM_DIR, '/Artifacts.toml'];
    % download the latest Artifacts.toml file from Github if the file does not exist
    if ~isfile(GM_TOML)
        update_GM();
    end
    GM_COLL = read_artifact_toml();
    % define artifact path to return
    art_path = '';
    if isfield(GM_COLL, art_name)
        % the artifact tar.gz and nc location
        art_tar_gz = [GM_DIR, '/archives/', art_name, '.tar.gz'];
        art_nc = [GM_DIR, '/artifacts/', getfield(getfield(GM_COLL,art_name),'git_tree_sha1'), '/', art_name, '.nc'];
        % if the artifact exist, do nothing
        if isfile(art_tar_gz) && isfile(art_nc)
            art_path = art_nc;
        else
            % download the file
            disp('Artifact does not exisit, download the file now...');
            art_urls = getfield(getfield(GM_COLL,art_name),'urls');
            if iscell(art_urls)
                for tmp_url = art_urls
                    urlwrite(tmp_url, art_tar_gz);
                    if isfile(art_tar_gz)
                        break;
                    end
                end
            else
                urlwrite(art_urls, art_tar_gz);
            end
            % unzip the file
            if isfile(art_tar_gz)
                disp('Unzip the file now...');
                untar(art_tar_gz, [GM_DIR, '/artifacts/', getfield(getfield(GM_COLL,art_name),'git_tree_sha1')]);
            end
            % if the file is extracted
            if isfile(art_nc)
                art_path = art_nc;
            end
        end
    else
        disp('The artifact name is not in our collection, please verify the artifact name!');
        disp('The supported artifacts are:');
        disp(fieldnames(GM_COLL));
    end
end
