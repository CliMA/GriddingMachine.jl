module Partitioner

#import ..GriddingMachine: TropomiL2SIF

using DataFrames, JSON

include("/home/exgu/GriddingMachine.jl/src/borrowed/EmeraldIO.jl")
include("/home/exgu/GriddingMachine.jl/src/borrowed/EmeraldUtility.jl")


"""

    partition(dict::Dict)

Partition data into grid based on JSON dict given
- `dict` JSON dict containing information for partitioning/gridding

"""
function partition end;

partition(dict::Dict) = (
    _dict_file = dict["INPUT_MAP_SETS"];
    _dict_outm = dict["OUTPUT_MAP_SETS"];
    #_dict_vars = dict["INPUT_VAR_SETS"];
    #_dict_stds = "INPUT_STD_SETS" in keys(dict) ? dict["INPUT_STD_SETS"] : nothing;

    _reso = _dict_outm["SPATIAL_RESO"];

    _n_lon = Int(360/_reso);
    _n_lat = Int(180/_reso);

    gridded_data = Array{DataFrame}(undef, _n_lon, _n_lat);

    for i in range(1, _n_lon)
        for j in range(1, _n_lat)
            gridded_data[i, j] = DataFrame(lon=Float32[], lat=Float32[], sif=Float32[], time=Float64[]);
        end;
    end;
    
    folder = _dict_file["FOLDER"];
    y = _dict_file["YEAR"];
    m_start = _dict_file["START_MONTH"]; m_end = _dict_file["END_MONTH"];
    d_start = _dict_file["START_DAY"]; d_end = _dict_file["END_DAY"];

    if (isleapyear(y))
        month_days = MDAYS;
    else
        month_days = MDAYS_LEAP;
    end;

    for m in range(m_start, m_end)
        d_s = 1; d_e = month_days[m];
        if m == m_start d_s = d_start end;
        if m == m_end d_e = d_end end;

        for d in range(d_s, d_e)
            file_name = replace(_dict_file["FILE_NAME_PATTERN"], "year" => lpad(y, 4, "0"), "month" => lpad(m, 2, "0"), "day" => lpad(d, 2, "0"));
            lon_cur = read_nc("$(folder)/$(file_name)", "lon");
            lat_cur = read_nc("$(folder)/$(file_name)", "lat");
            sif_cur = read_nc("$(folder)/$(file_name)", "sif");
            time_cur = read_nc("$(folder)/$(file_name)", "TIME");
            for i in range(1, size(sif_cur)[1])
                _lon_i = ceil(Int, (lon_cur[i]+180)/_reso);
                _lat_i = ceil(Int, (lat_cur[i]+90)/_reso);
                push!(gridded_data[_lon_i, _lat_i], [lon_cur[i], lat_cur[i], sif_cur[i], time_cur[i]]);
            end;
        end;
    end;

    for i in range(1, _n_lon)
        for j in range(1, _n_lat)
            cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_$(lpad(i, 3, "0"))_$(lpad(j, 3, "0"))_$(y).nc";
            save_nc!(cur_file, gridded_data[i, j]; growable = true);
        end;
    end;

    return nothing
);

partition(JSON.parsefile("/home/exgu/GriddingMachine.jl/json/Partition/grid_TROPOMI.json"))


end # module
