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
    _dict_vars = dict["INPUT_VAR_SETS"];
    _dict_stds = "INPUT_STD_SETS" in keys(dict) ? dict["INPUT_STD_SETS"] : nothing;

    #Compute number of blocks along lon and lat
    _reso = _dict_outm["SPATIAL_RESO"];
    _n_lon = Int(360/_reso);
    _n_lat = Int(180/_reso);

    #Initialize array to store data
    gridded_data = Array{DataFrame}(undef, _n_lon, _n_lat);

    data_names = [];
    std_names = [];
    for k in eachindex(_dict_vars)
        push!(data_names, _dict_vars[k]["DATA_NAME"]);
    end;
    if _dict_stds !== nothing
        for k in eachindex(_dict_stds)
            push!(std_names, _dict_stds[k]["DATA_NAME"]);
        end;
    end;

    for i in range(1, _n_lon)
        for j in range(1, _n_lat)
            gridded_data[i, j] = DataFrame(lon=Float32[], lat=Float32[], time=Float64[]);
            for k in data_names
                gridded_data[i, j][!, k] = Float32[];
            end;
            for k in std_names
                gridded_data[i, j][!, k] = Float32[];
            end;
        end;
    end;

    grid_template = copy(gridded_data);
    
    folder = _dict_file["FOLDER"];
    y_start = _dict_file["START_YEAR"]; y_end = _dict_file["END_YEAR"];
    m_start = _dict_file["START_MONTH"]; m_end = _dict_file["END_MONTH"];
    d_start = _dict_file["START_DAY"]; d_end = _dict_file["END_DAY"];

    for y in range(y_start, y_end)

        m_s = y == y_start ? m_start : 1;
        m_e = y == y_end ? m_end : 12;

        month_days = isleapyear(y) ? MDAYS : MDAYS_LEAP;

        for m in range(m_s, m_e)
            
            d_s = m == m_start ? d_start : 1;
            d_e = m == m_end ? d_end : month_days[m];

            for d in range(d_s, d_e)
                file_name = replace(_dict_file["FILE_NAME_PATTERN"], "year" => lpad(y, 4, "0"), "month" => lpad(m, 2, "0"), "day" => lpad(d, 2, "0"));
                file_path = "$(folder)/$(file_name)";

                #Check if file already processed

                #Read data from file
                lon_cur = read_nc(file_path, "lon");
                lat_cur = read_nc(file_path, "lat");
                time_cur = read_nc(file_path, "TIME");
                data = Dict{String, Vector}()
                std = Dict{String, Vector}()

                for k in data_names
                    data[k] = read_nc(file_path, k);
                end;
                for k in std_names
                    std[k] = read_nc(file_path, k);
                end;

                for i in range(1, size(time_cur)[1])
                    _lon_i = ceil(Int, (lon_cur[i]+180)/_reso);
                    _lat_i = ceil(Int, (lat_cur[i]+90)/_reso);
                    data_row = [lon_cur[i], lat_cur[i], time_cur[i]];
                    for k in data_names
                        push!(data_row, data[k][i])
                    end;
                    for k in std_names
                        push!(data_row, std[k][i])
                    end;
                    push!(gridded_data[_lon_i, _lat_i], data_row);
                end;
            end;

            if (_dict_outm["PER_MONTH"])
                for i in range(1, _n_lon)
                    for j in range(1, _n_lat)
                        cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_$(lpad(i, 3, "0"))_$(lpad(j, 3, "0"))_$(lpad(y, 4, "0"))_$(lpad(m, 2, "0")).nc";
                        save_nc!(cur_file, gridded_data[i, j]);
                    end;
                end;
                gridded_data = copy(grid_template);
            end;

        end;

        if (!_dict_outm["PER_MONTH"])
            for i in range(1, _n_lon)
                for j in range(1, _n_lat)
                    cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_$(lpad(i, 3, "0"))_$(lpad(j, 3, "0"))_$(lpad(y, 4, "0")).nc";
                    save_nc!(cur_file, gridded_data[i, j]);
                end;
            end;
        end;
    end;

    return nothing
);

end # module
