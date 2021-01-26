###############################################################################
#
# Fetch data from the website
#
###############################################################################
"""
    fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)

Download RAW product data, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `year` Which year data to download
"""
function fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)
    # input USER_NAME and USER_PASS
    global USER_NAME, USER_PASS;
    if USER_NAME == "" && USER_PASS == ""
        @warn "Do not share your user name and password with others.";
        @info "Please indicate your user name for MODIS Data portal:";
        USER_NAME = readline();
        @info "Please indicate your password for MODIS Data portal:";
        USER_PASS = readline();
    end
    # judge if leap year
    TDAY     = isleapyear(year) ? 366 : 365;
    http_loc = "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.006/";
    fluo_loc = "", "/net/fluo/data2/data/MODIS/MOD15A2H.006/original/";

    #
    #
    # make this a general download function
    #
    #
    # fetch file list in each folder
    @info "Fetching file name to download...";
    list_urls = [];
    list_locs = [];
    @showprogress for doy in 1:8:10
        folder = parse_date(year, doy);
        download(http_loc * folder, "temp.html");
        for _line in readlines("temp.html")
            if contains(_line, ".hdf\">")
                _ini = findfirst("MOD15A2H", _line);
                _end = findfirst(".hdf", _line);
                _nam = _line[_ini[1]:_end[1]+3];
                push!(list_urls, http_loc * folder * _nam);
                push!(list_locs, fluo_loc * string(year) * "/" * _nam);
            end
        end
        rm("temp.html");
    end

    # download files if the file does not exist
    @info "Downloading files...";
    @showprogress for i in 1:10
        _url = list_urls[i];
        _loc = list_locs[i];
        if Sys.which("wget") !== nothing
            if !isfile(_loc)
                _lst = "$(_url) -O $(_loc)";
                _psd = "--user $(USER_NAME) --password $(USER_PASS)";
                #run(`wget $(_psd) $(_lst)`);
            end
            @show _url;
            @show _loc;
        else
            @warn "wget not found, exit the loop";
            break
        end
    end

    return nothing
end
