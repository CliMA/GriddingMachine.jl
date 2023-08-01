module Partitioner

#import ..GriddingMachine: TropomiL2SIF

using DataFrames: DataFrame, push!
using JSON
using NetcdfIO: read_nc, save_nc!, grow_nc!, append_nc!, switch_netcdf_lib!
using PolygonInbounds: inpoly2
using JLD2
using FileIO

include("borrowed/EmeraldUtility.jl")
include("partitioner/ModifyLogs.jl")
include("partitioner/partition_helper.jl")
include("partitioner/grid_helper.jl")

"""
    partition(dict::Dict)

Partition data into blocks based on JSON dict given
- `dict` JSON dict containing information for partitioning

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

    data_dims = ["lon_bnd_1", "lat_bnd_1", "lon_bnd_2", "lat_bnd_2", "lon_bnd_3", "lat_bnd_3", "lon_bnd_4", "lat_bnd_4"];

    #Parse data name, masking function, and scaling function
    data_info = [];
    for k in eachindex(_dict_vars)
        data_masking_f = _dict_vars[k]["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x));
        data_scaling_f = _dict_vars[k]["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict_vars[k]["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x));
        push!(data_info, (_dict_vars[k]["DATA_NAME"], data_masking_f, data_scaling_f));
    end;
    
    #Date information from JSON
    y_start = _dict_file["START_YEAR"]; y_end = _dict_file["END_YEAR"];
    m_start = _dict_file["START_MONTH"]; m_end = _dict_file["END_MONTH"];
    d_start = _dict_file["START_DAY"]; d_end = _dict_file["END_DAY"];
    d_step = _dict_file["DAY_STEP"];

    #Ensure that hdf4 is supported ***** To be altered
    if isfile("$(homedir())/.julia/conda/3/x86_64/lib/libnetcdf.so")
        switch_netcdf_lib!(use_default = false, user_defined = "$(homedir())/.julia/conda/3/x86_64/lib/libnetcdf.so");
    elseif isfile("$(homedir())/.julia/conda/3/lib/libnetcdf.so")
        switch_netcdf_lib!(use_default = false, user_defined = "$(homedir())/.julia/conda/3/lib/libnetcdf.so");
    end;
    
    #Loop over years
    for y in range(y_start, y_end)

        m_s = y == y_start ? m_start : 1;
        m_e = y == y_end ? m_end : 12;
        month_days = isleapyear(y) ? MDAYS_LEAP : MDAYS; #cumulative number of days after each month

        #Loop over months
        for m in range(m_s, m_e)

            out_locf = format_with_date(_dict_outm["FOLDER"], y; m = m);
            if !isdir(out_locf) mkpath(out_locf) end;

            #Initialize array to store data
            partitioned_data = Array{DataFrame}(undef, _n_lon, _n_lat);
            for i in range(1, _n_lon)
                for j in range(1, _n_lat)
                    partitioned_data[i, j] = DataFrame(month=Int[], iday=Int[], lon=Float32[], lat=Float32[]);
                    if "LON_BNDS" in keys(_dict_dims)
                        for dim in data_dims
                            partitioned_data[i, j][!, dim] = Float32[];
                        end;
                    end;
                    if "TIME_NAME" in keys(_dict_dims) partitioned_data[i, j][!, "time"] = Float64[]; end;
                    for info in data_info
                        partitioned_data[i, j][!, info[1]] = Float32[];
                    end;
                end;
            end;

            successful_files = [];
            d_s = (m == m_start && y == y_start) ? d_start : 1;
            d_e = (m == m_end && y == y_end) ? d_end : month_days[m+1]-month_days[m];

            for d in range(d_s, d_e; step = d_step)
                folder = format_with_date(_dict_file["FOLDER"], y; m = m, d = d, month_days = month_days);
                file_name_pattern = format_with_date(_dict_file["FILE_NAME_PATTERN"], y; m = m, d = d, month_days = month_days);

                if !isdir(folder)
                    @info "Folder $(folder) does not exist."
                    write_to_log(missing_file_log, file_name_pattern);
                    @info "Files of form $(file_name_pattern) are missing, skipping...";
                    continue;
                end;
                files = filter(x -> occursin(file_name_pattern, x), readdir(folder));
                if isempty(files)
                    write_to_log(missing_file_log, file_name_pattern);
                    @info "Files of form $(file_name_pattern) are missing, skipping...";
                    continue;
                end;

                for file_name in files
                    if (check_log_for_message(success_file_log, file_name))
                        @info "File $(file_name) is already processed, skipping...";
                        continue;
                    end;
                    @info "Partitioning $(file_name) ..."
                    
                    try
                        if _dict_file["IS_VECTOR"] process_vector_data(file_name, folder, _dict_dims, data_info, _reso, m, d, partitioned_data, month_days);
                        elseif _dict_file["SATELLITE_NAME"] == "MODIS" process_MODIS_data(file_name, folder, _dict_dims, data_info, _reso, m, d, partitioned_data, month_days);
                        end;
                        push!(successful_files, file_name);
                        remove_from_log(missing_file_log, file_name_pattern);
                    catch e
                        write_to_log(unsuccess_file_log, file_name)
                        @info "File $(file_name) processing unsuccessful";
                    end;
                end;
            end;

            #Save file
            @info "Saving files for $(lpad(y, 4, "0"))-$(lpad(m, 2, "0"))..."
            for i in range(1, _n_lon)
                for j in range(1, _n_lat)
                    cur_file = "$(out_locf)/$(_dict_outm["LABEL"])_R$(lpad(_reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(y, 4, "0"))_$(lpad(m, 2, "0")).nc";
                    !isfile(cur_file) ? save_nc!(cur_file, partitioned_data[i, j]; growable = true) : grow_nc!(cur_file, partitioned_data[i, j]);
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
    get_data_from_file!(data::DataFrame, file_path::String, nodes::Matrix, var_names::Vector{String})

Append data within the given polygonal region from a file to DataFrame 
- `data` DataFrame storing data cumulatively
- `file_path` Path to the file containing the desired data
- `nodes` Matrix of coordinates corresponding to the corners of the polygon (in counterclockwise order)
- `var_names` The names of the variables to be queried
"""
get_data_from_file!(data::DataFrame, file_path::String, nodes::Matrix, var_names::Vector{String}) = (
    if !isfile(file_path)
        @warn "File $(file_path) does not exist, skipping...";
        return nothing;
    end;
    #Read lon, lat, time from file
    months_cur = read_nc(file_path, "month");
    idays_cur = read_nc(file_path, "iday");
    lon_cur = read_nc(file_path, "lon");
    lat_cur = read_nc(file_path, "lat");

    #Find all points within the polygon and push datapoints
    #Note: points on the boundary might be ignored
    points = hcat(lon_cur, lat_cur);
    overlap_matrix = inpoly2(points, nodes);
    overlaps = overlap_matrix[:, 1] .|| overlap_matrix[:, 2];
    append!(data.month, months_cur[overlaps]);
    append!(data.iday, idays_cur[overlaps]);
    append!(data.lon, lon_cur[overlaps]);
    append!(data.lat, lat_cur[overlaps]);
    for var_name in var_names
        data_cur = read_nc(file_path, var_name);
        append!(data[!,var_name], data_cur[overlaps]);
    end;
);


"""
    get_data(folder::String, label::String, nodes::Matrix, year::Int, var_names::Vector{String}; reso::Int = 5, months::Vector{Int} = collect(1:12))
    get_data(folder::String, label::String, nodes::Matrix, year::Int, var_name::String; reso::Int = 5, months::Vector{Int} = collect(1:12))

Get data as DataFrame for the listed months; variables, satelite, polygonal region, and year specified
- `folder` Path to the folder storing the partitioned files
- `label` Label of the dataset
- `nodes` Matrix of coordinates corresponding to the corners of the polygon (in counterclockwise order)
- `year` The year of interest
- `var_names` The names of the variables to be queried
- `var_name` The name of a specific variable to be queried
- `reso` Resolution of the partition; default to 5
- `months` Months to get data from; default to collect(1:12)

#
    get_data(folder::String, label::String, nodes::Matrix, year_list::Vector{Int}, var_names::Vector{String}; reso::Int = 5, months::Vector{Int} = collect(1:12))

Get data as dictionary mapping from year to DataFrame for each listed year and months; variables, satellite, and polygonal region specified
- `folder` Path to the folder storing the partitioned files
- `label` Label of the dataset
- `nodes` Matrix of coordinates corresponding to the corners of the polygon (in counterclockwise order)
- `year_list` Vector of years
- `var_names` The names of the variables to be queried
- `var_name` The name of a specific variable to be queried
- `reso` Resolution of the partition; default to 5
- `months` Months to get data from; default to collect(1:12)
"""
function get_data end;

get_data(folder::String, label::String, nodes::Matrix, year::Int, var_names::Vector{String}; reso::Int = 5, months::Vector{Int} = collect(1:12)) = (
    
    data = DataFrame(month=Int[], iday=Int[], lon=Float32[], lat=Float32[]);
    for var_name in var_names
        data[!, var_name] = Float32[];
    end;

    @info "Querying data...";
    try
        min_i = floor(Int, (minimum(nodes[:, 1])+180)/reso+1);
        max_i = floor(Int, (maximum(nodes[:, 1])+180)/reso+1);
        min_j = floor(Int, (minimum(nodes[:, 2])+90)/reso+1);
        max_j = floor(Int, (maximum(nodes[:, 2])+90)/reso+1);
        for i in range(min_i, max_i)
            for j in range(min_j, max_j)
                for m in months
                    file_path = format_with_date("$(folder)/$(label)_R$(lpad(reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_year_month.nc", year; m = m);
                    get_data_from_file!(data, file_path, nodes, var_names);
                end;
            end;
        end;
        @info "Process complete";
    catch e
        @warn "Failed to query data. Process terminated";
    end;

    return data;
);

get_data(folder::String, label::String, nodes::Matrix, year::Int, var_name::String; reso::Int = 5, months::Vector{Int} = collect(1:12)) = (
    return get_data(folder, label, nodes, year, [var_name]; reso=reso, months=months);
);

get_data(folder::String, label::String, nodes::Matrix, year_list::Vector{Int}, var_names::Vector{String}; reso::Int = 5, months::Vector{Int} = collect(1:12)) = (
    dfs = Dict{Int, DataFrame}();
    for year in year_list
        dfs[year] = get_data(folder, label, nodes, year, var_names; reso=reso, months=months);
    end;
    return dfs;
);


"""
    get_data_as_nc(queried_locf::String, folder::String, label::String, nodes::Matrix, year::Int, var_names::Vector{String}; reso::Int = 5)

Get data within the given closed polygonal region and save as a NetCDF file. The file path is returned
- `queried_locf` Path to the folder storing the queried data
- `folder` Path to the folder storing the partitioned files
- `label` Label of the dataset
- `nodes` Matrix of coordinates corresponding to the corners of the polygon (in counterclockwise order)
- `year` The year of interest
- `var_names` The names of the variables to be queried
- `reso` Resolution of the partition; default to 5
- `per_month` Whether partitioned data is per month; default to false
"""
function get_data_as_nc end;

get_data_as_nc(queried_locf::String, folder::String, label::String, nodes::Matrix, year::Int, var_names::Vector{String}; reso::Int = 5) = (
    df = get_data(folder, label, nodes, year, var_names; reso=reso);
    cur_file = "$(queried_locf)/$(label)_$(lpad(year, 4, "0"))_Poly$(nodes).nc";
    save_nc!(cur_file, df);
    return cur_file;
);


"""
    grid_from_json(json_file::String)

Grid satellite data using information given in JSON file
- `json_file` Path to the JSON file
"""
function grid_from_json end;

grid_from_json(json_file::String) = (

    dict = JSON.parsefile(json_file);
    _dict_file = dict["INPUT_MAP_SETS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_outv = dict["OUTPUT_VAR_ATTR"];
    _dict_refs = dict["OUTPUT_REF_ATTR"];

    gridded_locf = _dict_grid["FOLDER"];
    
    reso = _dict_grid["LAT_LON_RESO"];
    
    for y in _dict_grid["YEARS"]
        @info "Gridding file for year $(lpad(y, 4, "0"))..."
        month_days = isleapyear(y) ? MDAYS_LEAP : MDAYS;
        data = zeros(Float32, 360*reso, 180*reso, month_days[end]);
        std = zeros(Float32, 360*reso, 180*reso, month_days[end]);
        count = zeros(Int, 360*reso, 180*reso, month_days[end]);

        for i in range(1, Int(360/_dict_file["RESO"]))
            for j in range(1, Int(180/_dict_file["RESO"]))
                for m in range(1, 12)
                    file_path = format_with_date("$(_dict_file["FOLDER"])/$(_dict_file["LABEL"])_R$(lpad(_dict_file["RESO"], 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_year_month.nc", y; m = m);
                    if isfile(file_path)
                        lon_cur = read_nc(file_path, "lon");
                        lat_cur = read_nc(file_path, "lat");
                        data_cur = read_nc(file_path, dict["INPUT_VAR"]);
                        std_cur = "INPUT_STD" in keys(dict) ? read_nc(file_path, dict["INPUT_STD"]) : nothing;
                        iday_cur = read_nc(file_path, "iday");
                        for k in range(1, length(data_cur))
                            grid_i = max(ceil(Int, (lon_cur[k]+180)*reso), 1);
                            grid_j = max(ceil(Int, (lat_cur[k]+90)*reso), 1);
                            data[grid_i, grid_j, iday_cur[k]] += (isnan(data_cur[k]) ? 0 : data_cur[k]);
                            count[grid_i, grid_j, iday_cur[k]] += (isnan(data_cur[k]) ? 0 : 1);
                            std[grid_i, grid_j, iday_cur[k]] += std_cur === nothing ? 0 : isnan(std_cur[k]) ? 0 : 1;
                        end;
                    end;
                end;
            end;
        end;
        
        _var_attr::Dict{String,String} = merge(_dict_outv,_dict_refs);
        _labeling = isnothing(_dict_grid["EXTRA_LABEL"]) ? _dict_grid["LABEL"] : _dict_grid["LABEL"] * "_" *_dict_grid["EXTRA_LABEL"];
        cur_locf = format_with_date(gridded_locf, y)
        if !isdir(cur_locf) mkpath(cur_locf) end;
        cur_file = "$(cur_locf)/$(_labeling)_$(reso)X_$(lpad(y, 4, "0"))_V$(_dict_grid["VERSION"])_grid_info.jld2";
        jldsave(cur_file; data, std, count);
        @info "Grid info file saved for year $(lpad(y, 4, "0"))";

        for temp in _dict_grid["TEMPORAL_RESO"]
            cur_data, cur_std, cur_count = grid_for_temporal_reso(data, std, count, parse(Int, temp[1:end-1]), temp[end:end], reso, month_days);
            cur_file = "$(cur_locf)/$(_labeling)_$(reso)X_$(temp)_$(lpad(y, 4, "0"))_V$(_dict_grid["VERSION"]).nc";
            save_nc!(cur_file, "data", cur_data ./ cur_count, _var_attr; var_dims = ["lon", "lat", "ind"]);
            append_nc!(cur_file, "std", cur_std ./ cur_count, _var_attr, ["lon", "lat", "ind"]);
            @info "File saved for year $(lpad(y, 4, "0")), temporal resolution $(temp)";
        end;
    end;

    @info "Process complete";
);


"""
    grid_for_temp(grid_locf::String, folder::String, label::String, reso::Int, y::Int, version::Int, var_attr::Dict{String, String}, temp_resos::Vector{String})

Grid satellite data using JLD2 file for multiple temporal resolutions
- `grid_locf` Folder for storing the gridded dataset
- `folder` Folder containing the JLD2 file
- `label` Dataset label
- `reso` Spatial resolution for data
- `y` Year for data
- `version` Version of data
- `var_attr` Attributes of variable
- `temp_resos` Vector of temporal resolutions to grid to
"""
function grid_for_temp end;

grid_for_temp(grid_locf::String, folder::String, label::String, reso::Int, y::Int, version::Int, var_attr::Dict{String, String}, temp_resos::Vector{String}) = (
    file = "$(folder)/$(label)_$(reso)X_$(lpad(y, 4, "0"))_V$(version)_grid_info.jld2";
    data = load(file, "data");
    std = load(file, "std");
    count = load(file, "count");
    month_days = isleapyear(y) ? MDAYS_LEAP : MDAYS;
    for temp in temp_resos
        cur_data, cur_std, cur_count = grid_for_temporal_reso(data, std, count, parse(Int, temp[1:end-1]), temp[end:end], reso, month_days);
        cur_file = "$(grid_locf)/$(label)_$(reso)X_$(temp)_$(lpad(y, 4, "0"))_V$(version).nc";
        save_nc!(cur_file, "data", cur_data ./ cur_count, var_attr; var_dims = ["lon", "lat", "ind"]);
        append_nc!(cur_file, "std", cur_std ./ cur_count, var_attr, ["lon", "lat", "ind"]);
        @info "File saved for year $(lpad(y, 4, "0")), temporal resolution $(temp)";
    end;
);

"""
    clean_files(folder::String, label::String, reso::Int, year::Int; per_month = false)

Clean files of a year
- `folder` Path to the folder storing the gridded files
- `label` Label of the dataset
- `reso` Resolution of the grid
- `year` The year of interest
- `per_month` Whether gridded data is per month; default to false
"""
function clean_files end;

clean_files(folder::String, label::String, reso::Int, year::Int; per_month = false) = (
    @info "Cleaning files...";
    for i in range(1, Int(360/reso))
        for j in range(1, Int(180/reso))
            if !per_month
                cur_file = "$(folder)/$(label)_R$(lpad(reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(year, 4, "0")).nc";
                rm(cur_file; force = true);
            else
                for m in range(1, 12)
                    cur_file = "$(folder)/$(label)_R$(lpad(reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(year, 4, "0"))_$(lpad(m, 2, "0")).nc";
                    rm(cur_file; force = true);
                end;
            end;
        end;
    end;
    @info "Process complete";
    return nothing
);

end; # module