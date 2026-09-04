#=
format_with_date(path::String, y::Int; m::Int = 1, d::Int = 1, month_days::Vector = isleapyear(y) ? MDAYS_LEAP : MDAYS) = (
    return replace(path, "year" => lpad(y, 4, "0"), "month" => lpad(m, 2, "0"), "day" => lpad(d, 2, "0"), "date" => lpad(d + month_days[m], 3, "0"), "yyyy" => lpad(mod(y, 1000), 2, "0"));
);

parse_date(date::Date) = (
    year = Dates.year(date);
    month = Dates.month(date);
    day = Dates.day(date);
    return year, month, day
)

get_files(folder::String, file_name_pattern::String) = (
    if !isdir(folder)
        @info "Folder $(folder) does not exist."
        @info "Files of form $(file_name_pattern) are missing, skipping...";
        return [];
    end;
    files = filter(x -> occursin(file_name_pattern, x), readdir(folder));
    if isempty(files)
        @info "Files of form $(file_name_pattern) are missing, skipping...";
        return[];
    end;
    return files
)

save_partitioned_files(y::Int, m::Int, n_lon::Int, n_lat::Int, out_locf::String, label::String, p_reso::Int, partitioned_data::Array) = (
    @info "Saving/growing partitioned files for $(lpad(y, 4, "0"))-$(lpad(m, 2, "0"))...";
    for i in range(1, n_lon)
        for j in range(1, n_lat)
            if nrow(partitioned_data[i, j]) == 0 continue; end;
            cur_file = "$(out_locf)/$(label)_R$(lpad(p_reso, 3, "0"))_LON$(lpad(i, 3, "0"))_LAT$(lpad(j, 3, "0"))_$(lpad(y, 4, "0"))_$(lpad(m, 2, "0")).nc";
            !isfile(cur_file) ? save_nc!(cur_file, partitioned_data[i, j]; growable = true) : grow_nc!(cur_file, partitioned_data[i, j]);
        end;
    end;
    partitioned_data = nothing;
)

add_to_JLD2(jld2_f::String, y::Int, data_info::Array, label::String, gridded_sum::Dict, gridded_count::Dict, g_reso::Int) = (
    grid_locf = format_with_date(jld2_f, y);
    if !isdir(grid_locf) mkpath(grid_locf) end;
    for info in data_info
        cur_file = "$(grid_locf)/$(label)_$(info[1])_$(lpad(y, 4, "0"))_daily_grid_$(g_reso)X.jld2";
        @info "Saving/growing daily grid for $(info[1])..."
        cur_data = gridded_sum[info[1]];
        cur_count = gridded_count[info[1]];
        if isfile(cur_file)
            cur_data += load(cur_file, "cur_data")
            cur_count += load(cur_file, "cur_count")
        end;
        jldsave(cur_file; cur_data, cur_count);
    end;
    gridded_sum = nothing;
    gridded_count = nothing;
)

initialize_partition_grid(dict_dims::Dict, n_lon::Int, n_lat::Int, data_info::Array) = (
    data_dims = ["lon_bnd_1", "lat_bnd_1", "lon_bnd_2", "lat_bnd_2", "lon_bnd_3", "lat_bnd_3", "lon_bnd_4", "lat_bnd_4"];
    partitioned_data = Array{DataFrame}(undef, n_lon, n_lat);
    for i in range(1, n_lon)
        for j in range(1, n_lat)
            partitioned_data[i, j] = DataFrame(month=Int[], iday=Int[], lon=Float32[], lat=Float32[]);
            if "LON_BNDS" in keys(dict_dims)
                for dim in data_dims
                    partitioned_data[i, j][!, dim] = Float32[];
                end;
            end;
            if "TIME_NAME" in keys(dict_dims) partitioned_data[i, j][!, "time"] = Float64[]; end;
            for info in data_info
                partitioned_data[i, j][!, info[1]] = Float32[];
            end;
        end;
    end;
    return partitioned_data
)

initialize_grid(data_info::Array, num_days::Int, g_reso::Int) = (
    gridded_sum = Dict{String, Array}();
    gridded_count = Dict{String, Array}();
    for info in data_info
        gridded_sum[info[1]] = zeros(360*g_reso, 180*g_reso, num_days);
        gridded_count[info[1]] = zeros(360*g_reso, 180*g_reso, num_days);
    end;
    return gridded_sum, gridded_count
);

partition_file(file_name::String, folder::String, dict_dims::Dict, data_info::Array, p_reso::Int, m::Int, d::Int, partitioned_data::Array, month_days::Vector, is_MODIS::Bool;
                partition_files::Bool = true, grid_files::Bool = false, gridded_sum::Dict = nothing, gridded_count::Dict = nothing, g_reso::Int = 1) = (

    if !partition_files && !grid_files return gridded_sum, gridded_count end;

    (lon_cur, lat_cur, lon_bnds_cur, lat_bnds_cur, time_cur, data) = is_MODIS ? read_MODIS_file(file_name, folder, dict_dims, data_info) : read_vector_file(file_name, folder, dict_dims, data_info);
    for i in range(1, size(lon_cur)[1])
        if partition_files
            _lon_i = max(1, ceil(Int, (lon_cur[i]+180)/p_reso));
            _lat_i = max(1, ceil(Int, (lat_cur[i]+90)/p_reso));
            data_row = [m, d+month_days[m], lon_cur[i], lat_cur[i]];
            if "LON_BNDS" in keys(dict_dims)
                for j in range(1, 4)
                    push!(data_row, lon_bnds_cur[i, j]);
                    push!(data_row, lat_bnds_cur[i, j]);
                end;
            end;
            if "TIME_NAME" in keys(dict_dims) push!(data_row, time_cur[i]); end;
        end;
        if grid_files
            grid_i = max(1, ceil(Int, (lon_cur[i]+180)*g_reso));
            grid_j = max(1, ceil(Int, (lat_cur[i]+90)*g_reso));
        end;
        for info in data_info
            if partition_files push!(data_row, data[info[1]][i]); end;
            if grid_files
                gridded_sum[info[1]][grid_i, grid_j, d] += (isnan(data[info[1]][i]) ? 0 : data[info[1]][i]);
                gridded_count[info[1]][grid_i, grid_j, d] += (isnan(data[info[1]][i]) ? 0 : 1);
            end;
        end;
        if partition_files push!(partitioned_data[_lon_i, _lat_i], data_row); end;
    end;

    return gridded_sum, gridded_count
)

read_vector_file(file_name::String, folder::String, dict_dims::Dict, data_info::Array) = (
    file_path = "$(folder)/$(file_name)";
    lon_cur = read_nc(file_path, dict_dims["LON_NAME"]);
    lat_cur = read_nc(file_path, dict_dims["LAT_NAME"]);
    lon_bnds_cur = "LON_BNDS" in keys(dict_dims) ? dict_dims["FLIP_BNDS"] ? read_nc(file_path, dict_dims["LON_BNDS"])' : read_nc(file_path, dict_dims["LON_BNDS"]) : nothing;
    lat_bnds_cur = "LAT_BNDS" in keys(dict_dims) ? dict_dims["FLIP_BNDS"] ? read_nc(file_path, dict_dims["LAT_BNDS"])' : read_nc(file_path, dict_dims["LAT_BNDS"]) : nothing;
    time_cur = "TIME_NAME" in keys(dict_dims) ? read_nc(file_path, dict_dims["TIME_NAME"]; transform = false) : nothing;

    data = Dict{String, Vector}();
    for info in data_info
        cur_data = read_nc(file_path, info[1]);
        cur_data = isnothing(info[2]) ? cur_data : (masking = x -> Base.invokelatest(info[2], x); masking.(cur_data));
        data[info[1]] = isnothing(info[3]) ? cur_data : (scaling = x -> Base.invokelatest(info[3], x); scaling.(cur_data));
    end;

    return lon_cur, lat_cur, lon_bnds_cur, lat_bnds_cur, time_cur, data
)

read_MODIS_file(file_name::String, folder::String, dict_dims::Dict, data_info::Array) = (
    file_path = "$(folder)/$(file_name)";

    #Read the desired variables and std from file and apply given functions
    data = Dict{String, Array}();
    for info in data_info
        cur_data = read_nc(file_path, info[1]);
        cur_data = isnothing(info[2]) ? cur_data : (masking = x -> Base.invokelatest(info[2], x); masking.(cur_data));
        cur_data = isnothing(info[3]) ? cur_data : (scaling = x -> Base.invokelatest(info[3], x); scaling.(cur_data));
        cur_data = cur_data';
        data[info[1]] = vcat(cur_data...);
    end;

    i_h = findfirst("h", file_name)[1];
    cur_h = parse(Int, file_name[i_h+1:i_h+2]);
    i_v = findfirst("v", file_name)[1];
    cur_v = parse(Int, file_name[i_v+1:i_v+2]);

    lon_cur = vcat(read_nc(dict_dims["LON_LAT_MAP"], "longitude", [cur_h+1, cur_v+1, :, :])...);
    lat_cur = vcat(read_nc(dict_dims["LON_LAT_MAP"], "latitude", [cur_h+1, cur_v+1, :, :])...);

    return lon_cur, lat_cur, nothing, nothing, nothing, data
);

grid_for_temporal_reso(data::Array, std::Array, count::Array, t_reso::Int, type::String, reso::Int, month_days::Vector) = (
    if type == "Y"
        @assert t_reso == 1 "Customized temporal resolution for year must be 1"
        cur_data = sum(data, dims = 3);
        cur_std = sum(std, dims = 3);
        cur_count = sum(count, dims = 3);
    elseif type == "M"
        @assert t_reso == 1 "Customized temporal resolution for month must be 1"
        cur_data = zeros(Float32, 360*reso, 180*reso, 12);
        cur_std = zeros(Float32, 360*reso, 180*reso, 12);
        cur_count = zeros(Float32, 360*reso, 180*reso, 12);
        for m in range(1, 12)
            cur_data[:,:,m] = sum(data[:, :, month_days[m]+1:month_days[m+1]], dims = 3)
            cur_std[:,:,m] = sum(std[:, :, month_days[m]+1:month_days[m+1]], dims = 3)
            cur_count[:,:,m] = sum(count[:, :, month_days[m]+1:month_days[m+1]], dims = 3)
        end;
    elseif type == "D"
        @assert 1 <= t_reso <= month_days[end] "Customized temporal resolution for day must be between 1 and number of days per year"
        cur_data = zeros(Float32, 360*reso, 180*reso, ceil(Int, month_days[end]/t_reso));
        cur_std = zeros(Float32, 360*reso, 180*reso, ceil(Int, month_days[end]/t_reso));
        cur_count = zeros(Float32, 360*reso, 180*reso, ceil(Int, month_days[end]/t_reso));
        for i in range(1, ceil(Int, month_days[end]/t_reso))
            cur_data[:,:,i] = sum(data[:, :, (i-1)*t_reso+1:min(i*t_reso, month_days[end])], dims = 3)
            cur_std[:,:,i] = sum(std[:, :, (i-1)*t_reso+1:min(i*t_reso, month_days[end])], dims = 3)
            cur_count[:,:,i] = sum(count[:, :, (i-1)*t_reso+1:min(i*t_reso, month_days[end])], dims = 3)
        end;
    end;

    return cur_data, cur_std, cur_count;
)
=#
