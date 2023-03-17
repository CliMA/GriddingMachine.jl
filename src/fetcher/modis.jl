"""

$(TYPEDEF)

Hierachy of AbstractMODIS500m
- [`MOD09A1v006`](@ref)
- [`MOD15A2Hv006`](@ref)

"""
abstract type AbstractMODIS500m end


"""

$(TYPEDEF)

MODIS/Terra Surface Reflectance 8-Day L3 Global 500 m SIN Grid

"""
Base.@kwdef struct MOD09A1v006 <: AbstractMODIS500m
    "Label of data"
    label::String = "MOD09A1"
    "Local directory to save the data"
    local_dir::String = "/net/fluo/data1/data/MODIS/MOD09A1.006/original/";
    "Portal website"
    portal_url::String = "https://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.006/";
end


"""

$(TYPEDEF)

MODIS/Terra Leaf Area Index/FPAR 8-Day L4 Global 500 m SIN Grid

"""
Base.@kwdef struct MOD15A2Hv006 <: AbstractMODIS500m
    "Label of data"
    label::String = "MOD15A2H"
    "Local directory to save the data"
    local_dir::String = "/net/fluo/data1/data/MODIS/MOD15A2H.006/original/";
    "Portal website"
    portal_url::String = "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.006/";
end



"""
"""
fetch_data!(dt::MOD15A2Hv006, year::Int) = (
    update_MODIS_password!();
    fetch_data!(dt.portal_url, dt.local_dir, year, dt.label);

    return nothing
);

fetch_data!(dt::MOD09A1v006, year::Int) = (
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
        #folder = parse_date(year, doy, ".") * "/";
        _folder = "/";
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
            break
        end;
    end;

    return nothing
);
