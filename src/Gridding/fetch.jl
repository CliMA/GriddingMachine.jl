###############################################################################
#
# Fetch data from the website
#
###############################################################################
"""
    fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)
    fetch_RAW!(data_url::String, data_loc::String, year::Int, label::String)

Download RAW product data, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `year` Which year data to download
- `data_url` Url to the website where to download the data
- `data_loc` Local folder to store the data
"""
function fetch_RAW!(dt::MOD15A2Hv006LAI, year::Int)
    update_MODIS_password!();

    data_url = "$(MODIS_PORTAL)/MOLT/MOD15A2H.006/";
    data_loc = "$(MODIS_HOME)/MOD15A2H.006/original/";

    fetch_RAW!(data_url, data_loc, year, "MOD15A2H");

    return nothing
end




function fetch_RAW!(dt::MOD09A1v006NIRv, year::Int)
    update_MODIS_password!();

    data_url = "$(MODIS_PORTAL)/MOLT/MOD09A1.006/";
    data_loc = "$(MODIS_HOME)/MOD09A1.006/original/";

    fetch_RAW!(data_url, data_loc, year, "MOD09A1");

    return nothing
end




function fetch_RAW!(
            data_url::String,
            data_loc::String,
            year::Int,
            label::String
)
    # number of days per year
    TDAY = isleapyear(year) ? 366 : 365;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    list_urls = [];
    list_locs = [];
    for doy in 1:8:TDAY
        folder = parse_date(year, doy);
        try
            @info "Fetching file list from $(data_url * folder)";
            download(data_url * folder, "temp.html");
            for _line in readlines("temp.html")
                if contains(_line, ".hdf\">")
                    _ini = findfirst(label, _line);
                    _end = findfirst(".hdf", _line);
                    _nam = _line[_ini[1]:_end[1]+3];
                    push!(list_urls, data_url * folder * _nam);
                    push!(list_locs, data_loc * string(year) * "/" * _nam);
                end
            end
            rm("temp.html");
        catch err
            @info "Unable to fetch files from $(folder), skip it...";
        end
    end

    # download files if the file does not exist
    @info "Downloading files...";
    @showprogress for i in eachindex(list_locs)
        _url = list_urls[i];
        _loc = list_locs[i];
        if Sys.which("wget") !== nothing
            if !isfile(_loc)
                _lst = `-q $(_url) -O $(_loc)`;
                _psd = `--user $(MODIS_USER_ID) --password $(MODIS_USER_PWD)`;
                run(`wget $(_psd) $(_lst)`);
            end
        else
            @warn "wget not found, exit the loop";
            break
        end
    end

    return nothing
end
