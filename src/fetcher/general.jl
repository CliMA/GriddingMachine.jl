#######################################################################################################################################################################################################
#
# Changes to the struct
# General
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

General struct to use with wget

# Fields

$(TYPEDFIELDS)

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


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
"""

    fetch_data!(dt::GeneralWgetData, year::Int)
    fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String, start_date::Tuple)

Fetch data from general website supported by wget, given
- `dt` general data struct
- `year` Which year of data to fetch
- `data_url` URL of the data
- `data_loc` Where to save the downloaded data
- `time_res` Time resolution in days
- `label` Label in the data that help the identification
- `format` Data format
- `start_date` Start date of the data

"""
function fetch_data! end

fetch_data!(dt::GeneralWgetData, year::Int) = (
    update_EARTHDATA_password!();
    fetch_data!(dt.portal_url, dt.local_dir, dt.time_res, year, dt.label, dt.format, dt.start_date);

    return nothing
);

fetch_data!(data_url::String, data_loc::String, time_res::Int, year::Int, label::String, format::String, start_date::Tuple) =(
    if !isdir(data_loc * string(year))
        @info "Directory does not exist, a new directory has been created!";
        mkpath(data_loc * string(year));
    end;

    # number of days per year and when to start
    nday = isleapyear(year) ? 366 : 365;
    if year > start_date[1]
        firstdoy = 1;
    elseif year == start_date[1]
        mdays = isleapyear(year) ? MDAYS_LEAP : MDAYS;
        firstdoy = mdays[start_date[2]] + start_date[3];
    else
        firstdoy = 366;
    end;

    # fetch file list in each folder
    @info "Fetching file name to download...";
    for doy in firstdoy:time_res:nday
        list_urls = [];
        list_locs = [];
        folder = doy_to_str(year, doy) * "/";
        try
            @info "Fetching file list from $(data_url * folder)";
            lst = `-q $(data_url * folder) -O temp.html`;
            psd = `--user $(EARTH_DATA_ID) --password $(EARTH_DATA_PWD)`;
            run(`wget $(psd) $(lst)`);
            for line in readlines("temp.html")
                if contains(line, ".$(format)\">") && contains(line, label)
                    i_ini = findfirst(label, line)[1];
                    i_end = findfirst(".$(format)", line)[1];
                    nam = line[i_ini:i_end+length(format)];
                    push!(list_urls, data_url * folder * nam);
                    push!(list_locs, data_loc * string(year) * "/" * nam);
                end;
            end;
            rm("temp.html");
        catch err
            @warn "Unable to fetch files from $(folder), skip it...";
        end;

        # download files if the file does not exist
        @showprogress for i in eachindex(list_locs)
            url = list_urls[i];
            loc = list_locs[i];
            if Sys.which("wget") !== nothing
                if !isfile(loc)
                    @info "Downloading file $(loc)...";
                    lst = `-q $(url) -O $(loc)`;
                    psd = `--user $(EARTH_DATA_ID) --password $(EARTH_DATA_PWD)`;
                    try
                        run(`wget $(psd) $(lst)`);
                    catch err
                        @warn "Unable to download file $(loc), delete the unfinished file...";
                        rm(loc; force = true);
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
    imonth = month_ind(year, doy);
    iday   = doy - (isleapyear(year) ? MDAYS_LEAP[imonth] : MDAYS[imonth]);

    return lpad(year, 4, "0") * "." * lpad(imonth, 2, "0") * "." * lpad(iday, 2, "0")
end
