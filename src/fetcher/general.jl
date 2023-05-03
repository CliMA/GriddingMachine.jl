"""

$(TYPEDEF)

General struct to use with wget

"""
mutable struct GeneralWgetData
    "Format of data"
    format::String
    "Label of data"
    label::String
    "Local directory to save the data"
    local_dir::String
    "Portal url"
    portal_url::String
    "Time resolution in days"
    time_res::Int
end


"""

Fetch data from the server. Supported methods are

$(METHODLIST)

"""
function fetch_data! end

"""

    fetch_data!(dt::GeneralWgetData, year::Int)

Fetch data from MODIS, given
- `dt` general data struct
- `year` Which year of data to fetch

"""
fetch_data!(dt::GeneralWgetData, year::Int) = (
    update_MODIS_password!();
    fetch_data!(dt.portal_url, dt.local_dir, dt.time_res, year, dt.label, dt.format);

    return nothing
);

"""

    fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String)

Download raw product data from MODIS, given
- `data_url` URL of the data
- `data_loc` Where to save the downloaded data
- `time_res` Time resolution in days
- `year` Which year of MODIS data to download
- `label` Label in the MODIS data that help the identification
- `format` Data format

"""
fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String) =(
    if !isdir(data_loc * string(year))
        @info "Directory does not exist, a new directory has been created!";
        mkpath(data_loc * string(year));
    end;

    # number of days per year
    _nday = isleapyear(year) ? 366 : 365;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    _list_urls = [];
    _list_locs = [];
    for _doy in 1:time_res:_nday
        _folder = doy_to_str(year, _doy) * "/";
        try
            @info "Fetching file list from $(data_url * _folder)";
            _lst = `-q $(data_url * _folder) -O temp.html`;
            _psd = `--user $(WGET_USER_ID) --password $(WGET_USER_PWD)`;
            run(`wget $(_psd) $(_lst)`);
            for _line in readlines("temp.html")
                if contains(_line, ".$(format)\">") && contains(_line, label)
                    _ini = findfirst(label, _line);
                    _end = findfirst(".$(format)", _line);
                    _nam = _line[_ini[1]:_end[1]+length(format)];
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
                _psd = `--user $(WGET_USER_ID) --password $(WGET_USER_PWD)`;
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
