#
# install the packages required
# install.packages("configr");
# install.packages("jsonlite")
#

# load the libraries
library(configr);
library(jsonlite);

# check if dir exists, if not make the dir
GM_DIR  <- path.expand("~/GMCollections");
GM_TOML <- paste(GM_DIR, "/Artifacts.toml", sep="");
if (!dir.exists(GM_DIR)) {
    dir.create(GM_DIR);
    dir.create(paste(GM_DIR, "/archives", sep=""));
    dir.create(paste(GM_DIR, "/artifacts", sep=""));
}

# function to update the Artifacts.toml file
update_GM <- function() {
    download.file("https://raw.githubusercontent.com/CliMA/GriddingMachine.jl/main/Artifacts.toml", GM_TOML);
}

# download the latest Artifacts.toml file from Github if the file does not exist
if (!file.exists(GM_TOML)) {
    update_GM();
}

# read the artifact library
GM_COLL <- read.config(file = GM_TOML);
GM_ARTS <- names(GM_COLL);

# function to download and unpack the artifacts
query_collection <- function(art_name) {
    if (is.element(art_name, GM_ARTS)) {
        # the artifact tar.gz and nc location
        art_tar_gz <- paste(GM_DIR, "/archives/", art_name, ".tar.gz", sep="");
        art_nc     <- paste(GM_DIR, "/artifacts/", GM_COLL[[art_name]]$`git-tree-sha1`, "/", art_name, ".nc", sep="");
        # if the artifact exist, do nothing
        if (file.exists(art_tar_gz) & file.exists(art_nc)) {
            # print("Artifact exisits already, do nothing.");
        }
        else {
            # download the file
            print("Artifact does not exisit, download the file now...");
            download_info <- GM_COLL[[art_name]]$download;
            for (tmp_info in download_info) {
                download.file(tmp_info$url, art_tar_gz);
                if (file.exists(art_tar_gz)) {
                    print("Downloading finished...");
                    break
                }
            }
            # unzip the file
            if (file.exists(art_tar_gz)) {
                print("Unzip the file now...");
                tar_dir <- paste(GM_DIR, "/artifacts/", GM_COLL[[art_name]]$`git-tree-sha1`, sep="");
                print(tar_dir);
                dir.create(tar_dir);
                untar(art_tar_gz, exdir = tar_dir);
                print("Unzipping finished.");
            }
        }
        return(art_nc)
    }
    else {
        print("The artifact name is not in our collection, please verify the artifact name!");
        print("The supported artifacts are:")
        print(GM_ARTS);
        return(NULL)
    }
}

# function to request data from the server
request_LUT <- function(art_name, lat, lon, cyc = 0, user = "Anonymous", interpolation = FALSE, server = "tofu.gps.caltech.edu", port = 5055) {
    if (is.element(art_name, GM_ARTS)) {
        # send a request to our web server
        if (interpolation) {
            int_str <- "true";
        }
        else {
            int_str <- "false";
        }
        tmp_url <- paste("http://", server, ":", port, "/request.json?user=", user, "&artifact=", art_name, "&lat=", lat, "&lon=", lon, "&cyc=", cyc, "&interpolate=", int_str, sep="");
        tmp_json <- jsonlite::fromJSON(tmp_url);
        # if the json has a key Result
        if (!is.element("Result", names(tmp_json))) {
            print("There is something wrong with the request, please check the details about it!");
            print(tmp_json);
            return(NULL)
        }
        else {
            # replace -9999 to NaN
            tmp_data <- tmp_json$Result;
            tmp_std <- tmp_json$Error;
            tmp_data[tmp_data == -9999] <- NaN;
            tmp_std[tmp_std == -9999] <- NaN;
            return(list("data" = tmp_data, "std" = tmp_std))
        }
    }
    else {
        ;
        print("The artifact name is not in our collection, please verify the artifact name!");
        print("The supported artifacts are:")
        print(GM_ARTS);
        return(NULL)
    }
}
