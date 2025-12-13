#=
###############################################################################
#
# Query MODIS ungridded data folder
#
###############################################################################
"""
    query_RAW(dt::AbstractUngriddedData,
              year::Int,
              days::Int) where {FT<:AbstractFloat}
    query_RAW(dt::MOD15A2Hv006LAI,
              year::Int) where {FT<:AbstractFloat}

Prepare parameters (file name and etc) to work on, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `year` AD year using format XXXX
- `days` How many days per cycle

Note that `query_RAW(dt, year)` function returns the follwings
- Folder in on Fluo server that contains files to process
- File name pattern, such as "MOD15A2H.AYYYYDOY.*.hdf"
- File name prefix, such as "MOD15A2H.A"
- Band name to process, such as "Lai_500m"
- Cache folder location to store generated CSV files
- Scaling and offset array [a,b] as in y=ax+b
- Mask of minimum and maximum values
"""
function query_RAW(
            dt::AbstractMODIS500m{FT},
            year::Int,
            days::Int
) where {FT<:AbstractFloat}
    # Querry the file information using data type
    _folder, _naming, _pref, _band, _cache, _mm = query_RAW(dt, year);

    # set time information for the gridding process
    date_start = DateTime("$(year)-01-01");
    date_stop  = DateTime("$(year)-12-31");
    date_dday  = Day(days);
    date_list  = date_start:date_dday:date_stop;

    # generate file list to process
    @info "Processing data for year $(year)";
    @info "Please wait while fetching file names...";
    params = [];
    for layer in eachindex(date_list)
        date_temp = date_list[layer];
        for _date in date_temp:Day(1):date_temp+Day(days-1)
            file_dict = ["YYYY" => lpad(Dates.year(_date)     , 4, "0"),
                         "DOY"  => lpad(Dates.dayofyear(_date), 3, "0")];
            file_temp = reduce(replace, file_dict, init=_naming);
            for _path in glob(file_temp, _folder)
                push!(params, [dt, layer, _path, _pref, _band, _cache, _mm]);
            end
        end
    end

    return params
end




function query_RAW(dt::MOD09A1v006NIRv{FT}, year::Int) where {FT<:AbstractFloat}
    _folder = joinpath("$(MODIS_HOME)/MOD09A1.006/original", string(year));
    _naming = "MOD09A1.AYYYYDOY.*.hdf";
    _prefix = "MOD09A1.A";
    _cache  = joinpath("$(MODIS_HOME)/MOD09A1.006/cache", string(year));
    _band   = ["sur_refl_b01", "sur_refl_b02"];

    return _folder, _naming, _prefix, _band, _cache, FT[-0.01,1.7]
end




function query_RAW(dt::MOD15A2Hv006LAI{FT}, year::Int) where {FT<:AbstractFloat}
    _folder = joinpath("$(MODIS_HOME)/MOD15A2H.006/original", string(year));
    _naming = "MOD15A2H.AYYYYDOY.*.hdf";
    _prefix = "MOD15A2H.A";
    _cache  = joinpath("$(MODIS_HOME)/MOD15A2H.006/cache", string(year));
    _band   = "Lai_500m";

    return _folder, _naming, _prefix, _band, _cache, FT[0,15]
end
=#
