module Partitioner

#import ..GriddingMachine: TropomiL2SIF

using DataFrames: DataFrame
using JSON: Dict, parsefile
using Meshes: hasintersect, Point, Ngon
using NetcdfIO: read_nc, save_nc!, grow_nc!
using PolygonInbounds: inpoly2

include("borrowed/EmeraldUtility.jl")
include("partitioner/ModifyLogs.jl")

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
    _dict_dims = dict["INPUT_DIM_SETS"];
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
    for k in eachindex(_dict_vars)
        data_masking_f = _dict_vars[k]["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x));
        data_scaling_f = _dict_vars[k]["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x));
        push!(data_info, (_dict_vars[k]["DATA_NAME"], data_masking_f, data_scaling_f));
    end;

    #Initialize array to store data
    gridded_data = Array{DataFrame}(undef, _n_lon, _n_lat);
    for i in range(1, _n_lon)
        for j in range(1, _n_lat)
            gridded_data[i, j] = DataFrame(lon=Float32[], lat=Float32[], time=Float64[]);
            for k in data_info
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

        successful_files = [];

        #Start (end) month is 1 (12) if currently not in start (end) year
        m_s = y == y_start ? m_start : 1;
        m_e = y == y_end ? m_end : 12;
        month_days = isleapyear(y) ? MDAYS_LEAP : MDAYS; #cumulative number of days after each month

        #Loop over months
        for m in range(m_s, m_e)
            
            #Start (end) day is 1 (31, 30, 29, or 28) if currently not in start (end) year and month
            d_s = (m == m_start && y == y_start) ? d_start : 1;
            d_e = (m == m_end && y == y_end) ? d_end : month_days[m+1]-month_days[m];

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
                if (check_log_for_message(success_file_log, file_name))
                    @info "File $(file_name) is already processed, skipping...";
                    continue;
                end;
                @info "Gridding $(file_name) ..."
                
                try
                    #Read lon, lat, and time data from file
                    lon_cur = read_nc(file_path, _dict_dims["LON_NAME"]);
                    lat_cur = read_nc(file_path, _dict_dims["LAT_NAME"]);
                    time_cur = read_nc(file_path, _dict_dims["TIME_NAME"]);

                    #Instantiate dicts for storing data and std
                    data = Dict{String, Vector}();

                    #Read the desired variables and std from file and apply given functions
                    for k in data_info
                        data[k[1]] = read_nc(file_path, k[1]);
                        data[k[1]] = isnothing(k[2]) ? data[k[1]] : k[2].(data[k[1]]);
                        data[k[1]] = isnothing(k[3]) ? data[k[1]] : k[3].(data[k[1]]);
                    end;

                    #Loop over all data and push datapoint to corresponding block in the grid
                    for i in range(1, size(time_cur)[1])
                        _lon_i = max(1, ceil(Int, (lon_cur[i]+180)/_reso));
                        _lat_i = max(1, ceil(Int, (lat_cur[i]+90)/_reso));
                        data_row = [lon_cur[i], lat_cur[i], time_cur[i]];
                        for k in data_info
                            push!(data_row, data[k[1]][i]);
                        end;
                        push!(gridded_data[_lon_i, _lat_i], data_row);
                    end;

                    #Add file to successful_files array and remove from missing log
                    push!(successful_files, file_name);
                    remove_from_log(missing_file_log, file_name);

                catch e
                    write_to_log(unsuccess_file_log, file_name)
                    @info "File $(file_name) processing unsuccessful";
                end;
            end;

            #Save file for each month if set PER_MONTH to true
            if (_dict_outm["PER_MONTH"])
                @info "Saving files for $(lpad(y, 4, "0")), $(lpad(m, 2, "0"))..."
                for i in range(1, _n_lon)
                    for j in range(1, _n_lat)
                        cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_R$(lpad(_reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(y, 4, "0"))_$(lpad(m, 2, "0")).nc";
                        if !isfile(cur_file)
                            save_nc!(cur_file, gridded_data[i, j]; growable = true);
                        else
                            grow_nc!(cur_file, gridded_data[i, j]);
                        end;
                    end;
                end;
                gridded_data = copy(grid_template);
                for f in successful_files
                    append_to_log(success_file_log, f);
                    remove_from_log(unsuccess_file_log, f);
                end;
                successful_files = [];
            end;
        end;

        #Save file for each year if set PER_MONTH to false
        if (!_dict_outm["PER_MONTH"])
            @info "Saving files for $(lpad(y, 4, "0"))..."
            for i in range(1, _n_lon)
                for j in range(1, _n_lat)
                    cur_file = "$(_dict_outm["FOLDER"])/$(_dict_outm["LABEL"])_R$(lpad(_reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(y, 4, "0")).nc";
                    if !isfile(cur_file)
                        save_nc!(cur_file, gridded_data[i, j]; growable = true);
                    else
                        grow_nc!(cur_file, gridded_data[i, j]);
                    end;
                end;
            end;
            for f in successful_files
                append_to_log(success_file_log, f);
                remove_from_log(unsuccess_file_log, f);
            end;
        end;
    end;
    @info "Process complete";

    return nothing
);


"""
    get_data(folder::String, label::String, reso::Int, poly::Matrix, y::Int, var_name::String)

Get data from a specific satelite within the given closed polygonal region of a year
- `folder` Path to the folder storing the gridded files
- `label` Label of the dataset
- `reso` Resolution of the grid
- `dict` JSON dict containing information for the gridded dataset
- `poly` Vector of coordinates corresponding to the corners of the polygon (in counterclockwise order)
- `y` The year of interest
- `var_name` The variable name of the queried data
"""
function get_data end;

get_data(folder::String, label::String, reso::Int, poly::Vector, y::Int, var_name::String) = (

    polygon = Ngon(poly);
    nodes = Array{Float32}(undef, length(poly), 2);
    for i in range(1, length(poly))
        nodes[i, 1] = poly[i][1];
        nodes[i, 2] = poly[i][2];
    end;

    data = DataFrame(lon=Float32[], lat=Float32[], time=Float64[]);
    data[!, var_name] = Float32[];

    @info "Querying data...";
    try
        for lon in range(-180, 180-reso; step=reso)
            for lat in range(-90, 90-reso; step=reso)
                i = Int((lon+180)/reso+1);
                j = Int((lat+90)/reso+1);
                file_path = "$(folder)/$(label)_R$(lpad(reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(y, 4, "0")).nc"
                if !isfile(file_path)
                    @warn "File $(file_path) does not exist";
                    continue;
                end;
                grid_cell = Ngon((lon, lat), (lon+reso, lat), (lon+reso, lat+reso), (lon, lat+reso));
                println("i: $(i), j: $(j)");

                if hasintersect(polygon, grid_cell)
                    #Read lon, lat, time, and desired data from file
                    lon_cur = read_nc(file_path, "lon");
                    lat_cur = read_nc(file_path, "lat");
                    time_cur = read_nc(file_path, "time");
                    data_cur = read_nc(file_path, var_name);

                    #Find all points within the polygon and push datapoints
                    #Note: points on the boundary might be ignored
                    points = hcat(lon_cur, lat_cur);
                    overlaps = inpoly2(points, nodes)[:, 1];
                    append!(data.lon, lon_cur[overlaps]);
                    append!(data.lat, lat_cur[overlaps]);
                    append!(data.time, time_cur[overlaps]);
                    append!(data[!,var_name], data_cur[overlaps]);
                end;
            end;
        end;
        @info "Process complete";
    catch e
        @warn "Failed to query data. Process terminated";
    end;

    return data;
);


"""
    clean_files(folder::String, label::String, reso::Int, year::Int)

Get data from a specific satelite within the given closed polygonal region of a year
- `folder` Path to the folder storing the gridded files
- `label` Label of the dataset
- `reso` Resolution of the grid
- `year` The year of interest
"""
function clean_files end;

clean_files(folder::String, label::String, reso::Int, year::Int) = (
    @info "Cleaning files...";
    for i in range(1, Int(360/reso))
        for j in range(1, Int(180/reso))
            cur_file = "$(folder)/$(label)_R$(lpad(reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(year, 4, "0")).nc";
            rm(cur_file; force = true);
        end;
    end;
    @info "Process complete";
    return nothing
)

end; # module


