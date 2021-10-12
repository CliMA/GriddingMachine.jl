% function to parse Artifacts.toml file
function parsed_result = read_artifact_toml
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
    % read the file as string
    toml_str = fileread(GM_TOML);
    toml_lines = strsplit(toml_str, {'\n', '\r'});
    % parse the string (if not space) to a structure
    parsed_result = struct();
    art_key = '';
    art_sha = '';
    art_url = {};
    for tmp_line = toml_lines
        levels = length(strfind(tmp_line{1}, '['));
        if levels == 1
            % if not empty, append to structure
            if ~isempty(art_key)
                parsed_result.(art_key) = struct('git_tree_sha1', art_sha, 'urls', art_url);
                % restart
                art_key = '';
                art_sha = '';
                art_url = {};
            end
            art_key = tmp_line{1}(levels+1:end-levels);
        end
        if length(strfind(tmp_line{1}, 'git-tree-sha1 =')) == 1
            tmp_inds = strfind(tmp_line{1}, '"');
            art_sha = tmp_line{1}(tmp_inds(1)+1:tmp_inds(2)-1);
        end
        if length(strfind(tmp_line{1}, 'url ='))
            tmp_inds = strfind(tmp_line{1}, '"');
            tmp_url = tmp_line{1}(tmp_inds(1)+1:tmp_inds(2)-1);
            art_url = [art_url tmp_url];
        end
    end
    if ~isempty(art_key)
        parsed_result.(art_key) = struct('git_tree_sha1', art_sha, 'urls', art_url);
    end
end
