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
    "Start date"
    start_date::Tuple
end


"""

Fetch data from the server. Supported methods are

$(METHODLIST)

"""
function fetch_data! end

"""

    fetch_data!(dt::GeneralWgetData, year::Int)

Fetch data from general website supported by wget, given
- `dt` general data struct
- `year` Which year of data to fetch

"""
fetch_data!(dt::GeneralWgetData, year::Int) = (
    update_EARTHDATA_password!();
    fetch_data!(dt.portal_url, dt.local_dir, dt.time_res, year, dt.label, dt.format, dt.start_date);

    return nothing
);

"""

    fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String)

Download raw product data, given
- `data_url` URL of the data
- `data_loc` Where to save the downloaded data
- `time_res` Time resolution in days
- `year` Which year of data to download
- `label` Label in the data that help the identification
- `format` Data format

"""
fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String, start_date::Tuple) =(
    if !isdir(data_loc * string(year))
        @info "Directory does not exist, a new directory has been created!";
        mkpath(data_loc * string(year));
    end;

    # number of days per year and when to start
    _nday = isleapyear(year) ? 366 : 365;
    if year > start_date[1]
        _1stdoy = 1;
    elseif year == start_date[1]
        _mdays = isleapyear(year) ? MDAYS_LEAP : MDAYS;
        _1stdoy = _mdays[start_date[2]] + start_date[3];
    else
        _1stdoy = 366;
    end;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    for _doy in _1stdoy:time_res:_nday
        _list_urls = [];
        _list_locs = [];
        _folder = doy_to_str(year, _doy) * "/";
        try
            @info "Fetching file list from $(data_url * _folder)";
            _lst = `-q $(data_url * _folder) -O temp.html`;
            _psd = `--user $(EARTH_DATA_ID) --password $(EARTH_DATA_PWD)`;
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
            @warn "Unable to fetch files from $(_folder), skip it...";
        end;

        # download files if the file does not exist
        @showprogress for _i in eachindex(_list_locs)
            _url = _list_urls[_i];
            _loc = _list_locs[_i];
            if Sys.which("wget") !== nothing
                if !isfile(_loc)
                    @info "Downloading file $(_loc)...";
                    _lst = `-q $(_url) -O $(_loc)`;
                    _psd = `--user $(EARTH_DATA_ID) --password $(EARTH_DATA_PWD)`;
                    try
                        run(`wget $(_psd) $(_lst)`);
                    catch err
                        @warn "Unable to download file $(_loc), delete the unfinished file...";
                        rm(_loc; force = true);
                    end;
                end;
            else
                @warn "wget not found, exit the loop";
                break;
            end;
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
