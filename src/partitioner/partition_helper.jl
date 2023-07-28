
format_with_date(path::String, y::Int; m::Int = 1, d::Int = 1, month_days::Vector = isleapyear(y) ? MDAYS_LEAP : MDAYS) = (
    return replace(path, "year" => lpad(y, 4, "0"), "month" => lpad(m, 2, "0"), "day" => lpad(d, 2, "0"), "date" => lpad(d + month_days[m], 3, "0"), "yyyy" => lpad(mod(y, 1000), 2, "0"));
)

process_vector_data(file_name::String, folder::String, _dict_dims::Dict, data_info::Array, _reso::Int, m::Int, d::Int, partitioned_data, month_days::Vector) = (
    file_path = "$(folder)/$(file_name)";

    #Read lon, lat, and time data from file
    lon_cur = read_nc(file_path, _dict_dims["LON_NAME"]);
    lat_cur = read_nc(file_path, _dict_dims["LAT_NAME"]);
    lon_bnds_cur = "LON_BNDS" in keys(_dict_dims) ? read_nc(file_path, _dict_dims["LON_BNDS"]) : nothing;
    lon_bnds_cur = size(lon_bnds_cur)[2] == 4 ? lon_bnds_cur : lon_bnds_cur';
    lat_bnds_cur = "LAT_BNDS" in keys(_dict_dims) ? read_nc(file_path, _dict_dims["LAT_BNDS"]) : nothing;
    lat_bnds_cur = size(lat_bnds_cur)[2] == 4 ? lat_bnds_cur : lat_bnds_cur';
    time_cur = "TIME_NAME" in keys(_dict_dims) ? read_nc(file_path, _dict_dims["TIME_NAME"]; transform = false) : nothing;

    #Read the desired variables and std from file and apply given functions
    data = Dict{String, Vector}();
    for info in data_info
        cur_data = read_nc(file_path, info[1]);
        cur_data = isnothing(info[2]) ? cur_data : info[2].(cur_data);
        data[info[1]] = isnothing(info[3]) ? cur_data : info[3].(cur_data);
    end;

    #Loop over all data and push datapoint to corresponding block in the partition
    for i in range(1, size(lon_cur)[1])
        _lon_i = max(1, ceil(Int, (lon_cur[i]+180)/_reso));
        _lat_i = max(1, ceil(Int, (lat_cur[i]+90)/_reso));
        data_row = [m, d+month_days[m], lon_cur[i], lat_cur[i]];
        if "LON_BNDS" in keys(_dict_dims)
            for j in range(1, 4)
                push!(data_row, lon_bnds_cur[i, j]);
                push!(data_row, lat_bnds_cur[i, j]);
            end;
        end;
        if "TIME_NAME" in keys(_dict_dims) push!(data_row, time_cur[i]); end;
        for info in data_info
            push!(data_row, data[info[1]][i]);
        end;
        push!(partitioned_data[_lon_i, _lat_i], data_row);
    end;
);

process_MODIS_data(file_name::String, folder::String, _dict_dims::Dict, data_info::Array, _reso::Int, m::Int, d::Int, partitioned_data, month_days::Vector) = (
    file_path = "$(folder)/$(file_name)";

    #Read the desired variables and std from file and apply given functions
    data = Dict{String, Array}();
    for info in data_info
        cur_data = read_nc(file_path, info[1]);
        cur_data = isnothing(info[2]) ? cur_data : info[2].(cur_data);
        cur_data = isnothing(info[3]) ? cur_data : info[3].(cur_data);
        cur_data = cur_data';
        data[info[1]] = vcat(cur_data...);
    end;

    i_h = findfirst("h", file_name)[1];
    cur_h = parse(Int, file_name[i_h+1:i_h+2]);
    i_v = findfirst("v", file_name)[1];
    cur_v = parse(Int, file_name[i_v+1:i_v+2]);

    lon_cur = vcat(read_nc(_dict_dims["LON_LAT_MAP"], "longitude", [cur_h+1, cur_v+1, :, :])...);
    lat_cur = vcat(read_nc(_dict_dims["LON_LAT_MAP"], "latitude", [cur_h+1, cur_v+1, :, :])...);

    for i in range(1, size(lon_cur)[1])
        _lon_i = max(1, ceil(Int, (lon_cur[i]+180)/_reso));
        _lat_i = max(1, ceil(Int, (lat_cur[i]+90)/_reso));
        data_row = [m, d+month_days[m], lon_cur[i], lat_cur[i]];
        for info in data_info
            push!(data_row, data[info[1]][i]);
        end;
        push!(partitioned_data[_lon_i, _lat_i], data_row);
    end;
    
);