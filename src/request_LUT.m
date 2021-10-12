% function to request data from the server
function [out_data, out_std] = request_LUT(art_name, lat, lon, varargin)
    p = inputParser;
    p.addParameter('cyc', 0);
    p.addParameter('user', 'Anonymous');
    p.addParameter('interpolation', false);
    p.addParameter('server', 'tofu.gps.caltech.edu');
    p.addParameter('port', 5055);
    p.parse(varargin{:});
    cyc = p.Results.cyc;
    user = p.Results.user;
    interpolation = p.Results.interpolation;
    server = p.Results.server;
    port = p.Results.port;

    % try to load the jsonstuff for octave
    try
        jsondecode('{"a": "b"}');
    catch
        % if not working install and load
        try
            pkg load jsonstuff;
        catch
            disp("Install jsonstuff for Octave...");
            pkg install https://github.com/apjanke/octave-jsonstuff/releases/download/v0.3.3/jsonstuff-0.3.3.tar.gz;
            pkg load jsonstuff;
        end
    end
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
    GM_ARTS = fieldnames(GM_COLL);
    % define data and std ti return
    out_data = NaN;
    out_std = NaN;
    if isfield(GM_COLL, art_name)
        % send a request to our web server
        if interpolation
            int = 'true';
        else
            int = 'false';
        end
        url = ['http://', server, ':', int2str(port), '/request.json?user=', user, '&artifact=', art_name, '&lat=', num2str(lat), '&lon=', num2str(lon), '&cyc=', int2str(cyc), '&interpolate=', int];
        response = urlread(url);
        json = jsondecode(response);
        % if the json has a key Result
        if isfield(json, 'Result')
            tmp_data = json.Result;
            tmp_std = json.Error;
            tmp_data(tmp_data == -9999) = NaN;
            tmp_std(tmp_std == -9999) = NaN;
            out_data = tmp_data;
            out_std = tmp_std;
        else
            disp('There is something wrong with the request, please check the details about it!');
            disp(json);
        end
    else
        disp('The artifact name is not in our collection, please verify the artifact name!');
        disp('The supported artifacts are:')
        disp(GM_ARTS);
    end
end
