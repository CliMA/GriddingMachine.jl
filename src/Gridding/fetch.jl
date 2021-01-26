###############################################################################
#
# Fetch data from the website
#
###############################################################################
"""
    fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)
    fetch_RAW!(http_loc::String, fluo_loc::String)

Download RAW product data, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `year` Which year data to download
- `data_url` Url to the website where to download the data
- `data_loc` Local folder to store the data
"""
function fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)
    update_password();

    data_url = "$(MODIS_PORTAL)/MOLT/MOD15A2H.006/";
    data_loc = "$(MODIS_HOME)/MOD15A2H.006/original/";

    fetch_RAW!(data_url, data_loc);

    return nothing
end




function fetch_RAW!(data_url::String, data_loc::String)
    # number of days per year
    TDAY = isleapyear(year) ? 366 : 365;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    list_urls = [];
    list_locs = [];
    @showprogress for doy in 1:8:TDAY
        folder = parse_date(year, doy);
        download(data_url * folder, "temp.html");
        for _line in readlines("temp.html")
            if contains(_line, ".hdf\">")
                _ini = findfirst("MOD15A2H", _line);
                _end = findfirst(".hdf", _line);
                _nam = _line[_ini[1]:_end[1]+3];
                push!(list_urls, data_url * folder * _nam);
                push!(list_locs, data_loc * string(year) * "/" * _nam);
            end
        end
        rm("temp.html");
    end

    # download files if the file does not exist
    @info "Downloading files...";
    @showprogress for i in eachindex(list_locs)
        _url = list_urls[i];
        _loc = list_locs[i];
        if Sys.which("wget") !== nothing
            if !isfile(_loc)
                _lst = `-q $(_url) -O $(_loc)`;
                _psd = `--user $(USER_NAME) --password $(USER_PASS)`;
                run(`wget $(_psd) $(_lst)`);
            end
        else
            @warn "wget not found, exit the loop";
            break
        end
    end

    return nothing
end
