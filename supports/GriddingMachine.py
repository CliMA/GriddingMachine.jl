#
# This script depends on the following packages, please install them
# - json
# - numpy
# - os
# - tarfile
# - toml
# - urllib
#

# import necessary supports
from json           import loads
from numpy          import array, nan
from os             import mkdir
from os.path        import expanduser, isdir, isfile
from tarfile        import open
from toml           import load
from urllib.request import urlopen, urlretrieve

# check if dir exists, if not make the dir
GM_DIR  = expanduser("~") + "/GMCollections";
GM_TOML = GM_DIR + "/Artifacts.toml";
if not isdir(GM_DIR):
    mkdir(GM_DIR);
    mkdir(GM_DIR + "/archives");
    mkdir(GM_DIR + "/artifacts");

# function to update the Artifacts.toml file
def update_GM():
    urlretrieve("https://raw.githubusercontent.com/CliMA/GriddingMachine.jl/main/Artifacts.toml", GM_TOML);
    pass

# download the latest Artifacts.toml file from Github if the file does not exist
if not isfile(GM_TOML):
    update_GM();

# read the artifact library
GM_COLL = load(GM_TOML);
GM_ARTS = GM_COLL.keys();

# function to download and unpack the artifacts
def query_collection(art_name:str):
    if (art_name in GM_ARTS):
        # the artifact tar.gz and nc location
        art_tar_gz = GM_DIR + "/archives/" + art_name + ".tar.gz";
        art_nc = GM_DIR + "/artifacts/" + GM_COLL[art_name]["git-tree-sha1"] + "/" + art_name + ".nc";
        # if the artifact exist, do nothing
        if isfile(art_tar_gz) & isfile(art_nc):
            # print("Artifact exisits already, do nothing.");
            pass
        # if the artifact does not exist, download and unzip the file
        else:
            # download the file
            print("Artifact does not exisit, download the file now...");
            download_info = GM_COLL[art_name]["download"];
            for _info in download_info:
                urlretrieve(_info["url"], art_tar_gz);
                if isfile(art_tar_gz):
                    print("Downloading finished...");
                    break
            # unzip the file
            if isfile(art_tar_gz):
                print("Unzip the file now...");
                tar_file = open(art_tar_gz, "r:gz");
                tar_file.extractall(GM_DIR + "/artifacts/" + GM_COLL[art_name]["git-tree-sha1"]);
                tar_file.close();
                print("Unzipping finished.");
        return art_nc
    else:
        print("The artifact name is not in our collection, please verify the artifact name!");
        print("The supported artifacts are:")
        print(GM_ARTS);
        pass

# function to request data from the server
def request_LUT(art_name:str, lat, lon, cyc:int = 0, user:str = "Anonymous", interpolation:bool = False, server:str = "tofu.gps.caltech.edu", port:int = 5055):
    if (art_name in GM_ARTS):
        # send a request to our web server
        if interpolation:
            _int = "true";
        else:
            _int = "false";
        _url = "http://" + server + ":" + str(port) + "/request.json?user=" + user + "&artifact=" + art_name +"&lat=" + str(lat) + "&lon=" + str(lon) + "&cyc=" + str(cyc) + "&interpolate=" + _int;
        _response = urlopen(_url);
        _json = loads(_response.read().decode())
        # if the json has a key Result
        if not ("Result" in _json.keys()):
            print("There is something wrong with the request, please check the details about it!");
            print(_json);
            pass
        else:
            # replace -9999 to NaN
            _data = _json["Result"];
            _std = _json["Error"];
            if type(_data) is list:
                _data_array = array(_data);
                _std_array = array(_std);
                _data_array[_data_array == -9999] = nan;
                _std_array[_std_array == -9999] = nan;
                return _data_array, _std_array
            else:
                if _data == -9999:
                    _data = nan
                if _std == -9999:
                    _std = nan
                return _data, _std
    else:
        print("The artifact name is not in our collection, please verify the artifact name!");
        print("The supported artifacts are:")
        print(GM_ARTS);
        pass
