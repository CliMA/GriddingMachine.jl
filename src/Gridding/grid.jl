###############################################################################
#
# Grid data
#
###############################################################################
"""
    grid_RAW!(param::Array)
    grid_RAW!(dt::MOD15A2Hv006LAI{FT},
              params::Array{Any,1}) where {FT<:AbstractFloat}
    grid_RAW!(dt::MOD15A2Hv006LAI{FT},
             params::Array{Array,1},
             nthread::Int) where {FT<:AbstractFloat}

Grid the data and save it to a csv file, given
- `param` Parameter sets to pass to different threads
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `params` Array of `param`
- `nthread` Number of threads to run the code in parallel
"""
function grid_RAW!(param::Array{Any,1})
    global MODIS_GRID_LAT, MODIS_GRID_LON;
    # unpack data;
    _layer  = param[1];
    _path   = param[2];
    _prefix = param[3];
    _band   = param[4];
    _cache  = param[5];
    _kb     = param[6];
    _mm     = param[7];

    # transform the data to CSV file
    pos_start = findfirst(_prefix, _path);
    hv_string = _path[pos_start[1]:end];
    outp_file = joinpath(_cache, hv_string * ".csv");

    # if file exists, skip
    if !isfile(outp_file)
        h,v     = parse_HV(hv_string);
        lat_mat = view(MODIS_GRID_LAT,h,v,:,:);
        lon_mat = view(MODIS_GRID_LON,h,v,:,:);
        dat_out = DataFrame();
        try
            dat_mat = Float32.(ncread(_path, _band));
            dim_lon = size(dat_mat,1);
            dim_lat = size(dat_mat,2);
            dat_mat .*= _kb[1];
            dat_mat .+= _kb[2];
            (dat_out).lay = ones(Int, dim_lon * dim_lat) * _layer;
            (dat_out).lat = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).lon = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).dat = ones(dim_lon * dim_lat) .* -9999;
            for i in 1:dim_lon, j in 1:dim_lat
                _data = view(dat_mat,i,j,:);
                _mask = (_data .> _mm[1]) .* (_data .< _mm[2]);
                if sum(_mask) > 0
                    (dat_out).lat[dim_lat*(i-1)+j] = lat_mat[i,j];
                    (dat_out).lon[dim_lat*(i-1)+j] = lon_mat[i,j];
                    (dat_out).dat[dim_lat*(i-1)+j] = mean(_data[_mask]);
                end
            end
        catch e
            @warn "An error occurred when reading the dataset, use NaN...";
            @show e;
            dat_mat .*= _kb[1];
            dat_mat .+= _kb[2];
            (dat_out).lay = ones(Int, 1) * _layer;
            (dat_out).lat = ones(1) .* -9999;
            (dat_out).lon = ones(1) .* -9999;
            (dat_out).dat = ones(1) .* -9999;
        end

        # save data
        mask = ((dat_out).dat .> -1);
        CSV.write(outp_file, dat_out[mask,:]);
    end

    return nothing
end




function grid_RAW!(
            dt::MOD15A2Hv006LAI{FT},
            params::Array{Any,1}
) where {FT<:AbstractFloat}
    # load MODIS grid infomation
    load_MODIS!(dt);

    # run the gridding process
    @showprogress for param in params
        grid_RAW!(param);
    end

    return nothing
end




function grid_RAW!(
            dt::MOD15A2Hv006LAI{FT},
            params::Array{Any,1},
            nthread::Int
) where {FT<:AbstractFloat}
    # create threads
    dynamic_workers!(nthread);

    # load MODIS grid infomation
    @everywhere load_MODIS!($dt);

    # run the gridding process
    @showprogress pmap(grid_RAW!, params);

    return nothing
end
