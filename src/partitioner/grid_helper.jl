grid_for_temporal_reso(data, std, count, t_reso, type, reso, month_days) = (
    if type == "Y"
        @assert t_reso == 1 "Customized temporal resolution for year must be 1"
        cur_data = sum(data, dims = 3);
        cur_std = sum(std, dims = 3);
        cur_count = sum(count, dims = 3);
    elseif type == "M"
        @assert 1 <= t_reso <= 12 "Customized temporal resolution for month must be 1"
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