% function to update the Artifacts.toml file
function update_GM
    % define paths
    if ispc
        HOME = [getenv('HOMEDRIVE'),getenv('HOMEPATH')];
    else
        HOME = getenv('HOME');
    end
    GM_DIR  = [HOME, '/GMCollections'];
    GM_TOML = [GM_DIR, '/Artifacts.toml'];
    if ~isfolder(GM_DIR)
        mkdir(GM_DIR);
        mkdir([GM_DIR, '/archives']);
        mkdir([GM_DIR, '/artifacts']);
    end
    urlwrite('https://raw.githubusercontent.com/CliMA/GriddingMachine.jl/main/Artifacts.toml', GM_TOML);
end
