module Partitioner

#import ..GriddingMachine: TropomiL2SIF

using DataFrames, JSON

include("borrowed/EmeraldIO.jl")
include("borrowed/EmeraldUtility.jl")
include("borrowed/ModifyLogs.jl")

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
    _dict_logs = dict["LOG_FILES"];

    success_file_log = "$(_dict_logs["FOLDER"])/$(_dict_logs["SUCCESSFUL"])";
    unsuccess_file_log = "$(_dict_logs["FOLDER"])/$(_dict_logs["UNSUCCESSFUL"])";
    missing_file_log = "$(_dict_logs["FOLDER"])/$(_dict_logs["MISSING"])";

    #Compute number of blocks along lon and lat
    _reso = _dict_outm["SPATIAL_RESO"];
    _n_lon = Int(360/_reso);
    _n_lat = Int(180/_reso);

    #Parse data name, masking function, and scaling function
    data_info = [];
    std_info = [];
    for k in eachindex(_dict_vars)
        data_masking_f = _dict_vars[k]["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x));
        data_scaling_f = _dict_vars[k]["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x));
        push!(data_info, (_dict_vars[k]["DATA_NAME"], data_masking_f, data_scaling_f));
    end;
    if _dict_stds !== nothing
        for k in eachindex(_dict_stds)
            std_masking_f = _dict_stds[k]["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_stds[k]["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x));
            std_scaling_f = _dict_stds[k]["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_stds[k]["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x));
            push!(std_info, (_dict_stds[k]["DATA_NAME"], std_masking_f, std_scaling_f));
        end;
    end;

    #Initialize array to store data
    gridded_data = Array{DataFrame}(undef, _n_lon, _n_lat);
    for i in range(1, _n_lon)
        for j in range(1, _n_lat)
            gridded_data[i, j] = DataFrame(lon=Float32[], lat=Float32[], time=Float64[]);
            for k in data_info
                gridded_data[i, j][!, k[1]] = Float32[];
            end;
            for k in std_info
                gridded_data[i, j][!, k[1]] = Float32[];
            end;
        end;
    end;

    #Empty grid with dataframes set up
    grid_template = copy(gridded_data);
    
    #Folder and date information from JSON
    folder = _dict_file["FOLDER"];
    y_start = _dict_file["START_YEAR"]; y_end = _dict_file["END_YEAR"];
    m_start = _dict_file["START_MONTH"]; m_end = _dict_file["END_MONTH"];
    d_start = _dict_file["START_DAY"]; d_end = _dict_file["END_DAY"];

    #Create folder if it does not exist yet
    if !isdir(_dict_outm["FOLDER"])
        mkpath(_dict_outm["FOLDER"]);
    end;

    #Loop over years
    for y in range(y_start, y_end)

        #Start (end) month is 1 (12) if currently not in start (end) year
        m_s = y == y_start ? m_start : 1;
        m_e = y == y_end ? m_end : 12;

        #Get array corresponding to number of days in the 12 months of current year
        month_days = isleapyear(y) ? MDAYS : MDAYS_LEAP;

        #Loop over months
        for m in range(m_s, m_e)
            
            #Start (end) day is 1 (31, 30, 29, or 28) if currently not in start (end) year and month
            d_s = (m == m_start && y == y_start) ? d_start : 1;
            d_e = (m == m_end && y == y_end) ? d_end : month_days[m];

            for d in range(d_s, d_e)
                file_name = replace(_dict_file["FILE_NAME_PATTERN"], "year" => lpad(y, 4, "0"), "month" => lpad(m, 2, "0"), "day" => lpad(d, 2, "0"));
                file_path = "$(folder)/$(file_name)";

                #Check if file exists. If not, write to missing_files.log
                if !isfile(file_path)
                    write_to_log(missing_file_log, file_name);
                    @info "File $(file_name) is missing, skipping...";
                    continue;
                end;

                #Check if file already processed. If so, skip the file
                if (check_log_for_message(success_file_log, file_name)) continue; end;
                @info "Gridding $(file_name) ..."
                
                try
                    #Read lon, lat, and time data from file
                    lon_cur = read_nc(file_path, "lon");
                    lat_cur = read_nc(file_path, "lat");
                    time_cur = read_nc(file_path, "TIME");
                    data = Dict{String, Vector}();
                    std = Dict{String, Vector}();

                    #Read the desired variables and std from file and apply given functions
                    for k in data_info
                        data[k[1]] = read_nc(file_path, k[1]);
                        data[k[1]] = isnothing(k[2]) ? data[k[1]] : k[2].(data[k[1]]);
                        data[k[1]] = isnothing(k[3]) ? data[k[1]] : k[3].(data[k[1]]);
                    end;
                    for k in std_info
                        std[k[1]] = read_nc(file_path, k[1]);
                        std[k[1]] = isnothing(k[2]) ? std[k[1]] : k[2].(std[k[1]]);
                        std[k[1]] = isnothing(k[3]) ? std[k[1]] : k[3].(std[k[1]]);
                    end;

                    #Loop over all data and push datapoint to corresponding block in the grid
                    for i in range(1, size(time_cur)[1])
                        _lon_i = ceil(Int, (lon_cur[i]+180)/_reso);
                        _lat_i = ceil(Int, (lat_cur[i]+90)/_reso);
                        data_row = [lon_cur[i], lat_cur[i], time_cur[i]];
                        for k in data_info
                            push!(data_row, data[k[1]][i]);
                        end;
                        for k in std_info
                            push!(data_row, std[k[1]][i]);
                        end;
                        push!(gridded_data[_lon_i, _lat_i], data_row);
                    end;

                    #Add file to successful_files.log and remove from other logs
                    append_to_log(success_file_log, file_name);
                    remove_from_log(unsuccess_file_log, file_name);
                    remove_from_log(missing_file_log, file_name);

                catch e
                    write_to_log(unsuccess_file_log, file_name)
                    @info "File $(file_name) processing unsuccessful";
                end;
                
            end;

            #Save file for each month if set PER_MONTH to true
            if (_dict_outm["PER_MONTH"])
                for i in range(1, _n_lon)
                    for j in range(1, _n_lat)
                        cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_$(lpad(i, 3, "0"))_$(lpad(j, 3, "0"))_$(lpad(y, 4, "0"))_$(lpad(m, 2, "0")).nc";
                        save_nc!(cur_file, gridded_data[i, j]; growable = true);
                    end;
                end;
                gridded_data = copy(grid_template);
            end;
        end;

        #Save file for each year if set PER_MONTH to false
        if (!_dict_outm["PER_MONTH"])
            for i in range(1, _n_lon)
                for j in range(1, _n_lat)
                    cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_$(lpad(i, 3, "0"))_$(lpad(j, 3, "0"))_$(lpad(y, 4, "0")).nc";
                    save_nc!(cur_file, gridded_data[i, j]; growable = true);
                end;
            end;
        end;
    end;

    return nothing
);


function get_rectangle end;


Partitioner.partition(JSON.parsefile("/home/exgu/GriddingMachine.jl/json/Partition/grid_TROPOMI.json"));

end; # module


