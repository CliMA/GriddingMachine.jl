% Octave ought to support json since version 7, revise this then
% install the JsonStuff package for Octave
% pkg install https://github.com/apjanke/octave-jsonstuff/releases/download/v0.3.3/jsonstuff-0.3.3.tar.gz
pkg load jsonstuff

% check if dir exist, if not make the dir
if ispc
    global HOME = [getenv('HOMEDRIVE'),getenv('HOMEPATH')];
else
    global HOME = getenv('HOME');
endif

global GM_DIR  = [HOME, "/GMCollections"];
global GM_TOML = [GM_DIR, "/Artifacts.toml"];

if isfolder(GM_DIR)
    mkdir(GM_DIR);
    mkdir([GM_DIR, "/archives"]);
    mkdir([GM_DIR, "/artifacts"]);
endif;

% function to update the Artifacts.toml file
function update_GM
    global GM_TOML;
    urlwrite("https://raw.githubusercontent.com/CliMA/GriddingMachine.jl/main/Artifacts.toml", GM_TOML);
endfunction

% download the latest Artifacts.toml file from Github if the file does not exist
if !isfile(GM_TOML)
    update_GM();
endif

% function to parse Artifacts.toml file
function parsed_result = read_artifact_toml(file_name)
    % read the file as string
    toml_str = fileread(file_name);
    toml_lines = strsplit(toml_str, {"\n", "\r"});
    % parse the string (if not space) to a structure
    parsed_result = struct();
    art_key = "";
    art_sha = "";
    art_url = {};
    for tmp_line = toml_lines
        levels = length(strfind(tmp_line{1}, "["));
        if levels == 1
            % if not empty, append to structure
            if !isempty(art_key)
                disp(art_url);
                disp(struct("git-tree-sha1", art_sha, "urls", art_url));
                parsed_result.(art_key) = struct("git-tree-sha1", art_sha, "urls", art_url);
                % restart
                art_key = "";
                art_sha = "";
                art_url = {};
            endif;
            art_key = tmp_line{1}(levels+1:end-levels);
        endif;
        if length(strfind(tmp_line{1}, "git-tree-sha1 =")) == 1
            tmp_inds = strfind(tmp_line{1}, '"');
            art_sha = tmp_line{1}(tmp_inds(1)+1:tmp_inds(2)-1);
        endif;
        if length(strfind(tmp_line{1}, "url ="))
            tmp_inds = strfind(tmp_line{1}, '"');
            tmp_url = tmp_line{1}(tmp_inds(1)+1:tmp_inds(2)-1);
            art_url = [art_url tmp_url];
        endif;
    endfor;
    if !isempty(art_key)
        parsed_result.(art_key) = struct("git-tree-sha1", art_sha, "urls", art_url);
    endif;
endfunction

% read the artifact library
global GM_COLL = read_artifact_toml(GM_TOML);
global GM_ARTS = fieldnames(GM_COLL);

% function to download and unpack the artifacts
function art_path = query_collection(art_name)
    global GM_ARTS;
    global GM_COLL;
    global GM_DIR;
    art_path = "";
    if isfield(GM_COLL, art_name)
        % the artifact tar.gz and nc location
        art_tar_gz = [GM_DIR, "/archives/", art_name, ".tar.gz"];
        art_nc = [GM_DIR, "/artifacts/", getfield(getfield(GM_COLL,art_name),"git-tree-sha1"), "/", art_name, ".nc"];
        % if the artifact exist, do nothing
        if isfile(art_tar_gz) && isfile(art_nc)
            art_path = art_nc;
        else
            % download the file
            disp("Artifact does not exisit, download the file now...");
            art_urls = getfield(getfield(GM_COLL,art_name),"urls");
            if iscell(art_urls)
                for tmp_url = art_urls
                    urlwrite(tmp_url, art_tar_gz);
                    if isfile(art_tar_gz)
                        break;
                    endif;
                endfor;
            else
                urlwrite(art_urls, art_tar_gz);
            endif;
            % unzip the file
            if isfile(art_tar_gz)
                disp("Unzip the file now...");
                gunzip(art_tar_gz, [GM_DIR, "/artifacts/", getfield(getfield(GM_COLL,art_name),"git-tree-sha1")]);
            endif;
            % if the file is extracted
            if isfile(art_nc)
                art_path = art_nc;
            endif;
        endif;
    else
        disp("The artifact name is not in our collection, please verify the artifact name!");
        disp("The supported artifacts are:");
        disp(fieldnames(GM_COLL));
    endif;
endfunction;

% function to request data from the server
function [out_data, out_std] = request_LUT(art_name, lat, lon, cyc = 0, user = "Anonymous", interpolation = false, server = "tofu.gps.caltech.edu", port = 5055)
    global GM_ARTS;
    global GM_COLL;
    out_data = NaN;
    out_std = NaN;
    if isfield(GM_COLL, art_name)
        % send a request to our web server
        if interpolation
            int = "true";
        else
            int = "false";
        endif;
        url = ["http://", server, ":", int2str(port), "/request.json?user=", user, "&artifact=", art_name, "&lat=", num2str(lat), "&lon=", num2str(lon), "&cyc=", int2str(cyc), "&interpolate=", int];
        response = urlread(url);
        json = jsondecode(response);
        % if the json has a key Result
        if isfield(json, "Result")
            tmp_data = json.Result;
            tmp_std = json.Error;
            tmp_data(tmp_data == -9999) = NaN;
            tmp_std(tmp_std == -9999) = NaN;
            out_data = tmp_data;
            out_std = tmp_std;
        else
            disp("There is something wrong with the request, please check the details about it!");
            disp(json);
        endif;
    else
        disp("The artifact name is not in our collection, please verify the artifact name!");
        disp("The supported artifacts are:")
        disp(GM_ARTS);
    endif;
endfunction;

% Use these commands below to test the function for Octave and Matlab
% query_collection("WD_2X_1Y_V1")
% request_LUT("WD_2X_1Y_V1", 33, 115)
% request_LUT("LAI_MODIS_2X_1M_2020_V1", 33, 115)
