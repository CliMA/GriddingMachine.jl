"""

$(TYPEDEF)

General struct for 500 m resolution MODIS data

"""
mutable struct MODIS500m
    "Label of data"
    label::String
    "Local directory to save the data"
    local_dir::String
    "Portal url"
    portal_url::String
end

MOD09A1v006() = MODIS500m("MOD09A1", "/net/squid/data1/data/pooled/MODIS/MOD09A1.006/original/", "https://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.006/");
MOD15A2Hv006() = MODIS500m("MOD15A2H", "/net/squid/data1/data/pooled/MODIS/MOD15A2H.006/original/", "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.006/");
MOD15A2Hv061() = MODIS500m("MOD15A2H", "/net/squid/data1/data/pooled/MODIS/MOD15A2H.061/original/", "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.061/");


"""

    fetch_data!(dt::MODIS500m, year::Int)

Fetch data from MODIS, given
- `dt` MODIS data struct
- `year` Which year of data to fetch

"""
fetch_data!(dt::MODIS500m, year::Int) = (
    update_MODIS_password!();
    fetch_data!(dt.portal_url, dt.local_dir, year, dt.label);

    return nothing
);

"""

    fetch_data!(data_url::String, data_loc::String, year::Int, label::String)

Download raw product data from MODIS, given
- `data_url` URL of the data
- `data_loc` Where to save the downloaded data
- `year` Which year of MODIS data to download
- `label` Label in the MODIS data that help the identification

"""
fetch_data!(data_url::String, data_loc::String, year::Int, label::String) =(
    # number of days per year
    _nday = isleapyear(year) ? 366 : 365;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    _list_urls = [];
    _list_locs = [];
    for _doy in 1:8:_nday
        _folder = doy_to_str(year, _doy) * "/";
        try
            @info "Fetching file list from $(data_url * _folder)";
            download(data_url * _folder, "temp.html");
            for _line in readlines("temp.html")
                if contains(_line, ".hdf\">")
                    _ini = findfirst(label, _line);
                    _end = findfirst(".hdf", _line);
                    _nam = _line[_ini[1]:_end[1]+3];
                    push!(_list_urls, data_url * _folder * _nam);
                    push!(_list_locs, data_loc * string(year) * "/" * _nam);
                end;
            end;
            rm("temp.html");
        catch err
            @info "Unable to fetch files from $(_folder), skip it...";
        end;
    end;

    # download files if the file does not exist
    @info "Downloading files...";
    @showprogress for _i in eachindex(_list_locs)
        _url = _list_urls[_i];
        _loc = _list_locs[_i];
        if Sys.which("wget") !== nothing
            if !isfile(_loc)
                _lst = `-q $(_url) -O $(_loc)`;
                _psd = `--user $(MODIS_USER_ID) --password $(MODIS_USER_PWD)`;
                run(`wget $(_psd) $(_lst)`);
            end;
        else
            @warn "wget not found, exit the loop";
            break;
        end;
    end;

    return nothing
);


"""

    doy_to_str(year::Int, doy::Int)

Convert doy to string like "YYYY.MM.DD", given
- `year` Year number
- `doy` Day of year

"""
function doy_to_str(year::Int, doy::Int)
    # convert the year and doy to timestamp
    _month = month_ind(year, doy);
    _day   = doy - (isleapyear(year) ? MDAYS_LEAP[_month] : MDAYS[_month]);

    return lpad(year, 4, "0") * "." * lpad(_month, 2, "0") * "." * lpad(_day, 2, "0")
end
