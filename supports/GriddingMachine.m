% Octave ought to support json since version 7, revise this then
% install the JsonStuff package for Octave
% pkg install https://github.com/apjanke/octave-jsonstuff/releases/download/v0.3.3/jsonstuff-0.3.3.tar.gz
% pkg load jsonstuff

source("update_GM.m");
source("read_artifact_toml.m");
source("query_collection.m");
source("request_LUT.m");

% Use these commands below to test the function for Octave and Matlab
% update_GM();
query_collection('WD_2X_1Y_V1')
request_LUT('WD_2X_1Y_V1', 33, 115)
request_LUT('LAI_MODIS_2X_1M_2020_V1', 33, 115)
