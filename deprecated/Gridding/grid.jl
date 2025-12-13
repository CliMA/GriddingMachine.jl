#=
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
    grid_RAW!(param...);

    return nothing
end




function grid_RAW!(
            dt::MOD09A1v006NIRv{FT},
            nlayer::Int,
            path::String,
            prefix::String,
            band::Array{String,1},
            cache::String,
            mm::Array{FT,1}
) where {FT<:AbstractFloat}
    # transform the data to CSV file
    pos_start = findfirst(prefix, path);
    hv_string = path[pos_start[1]:end];
    outp_file = joinpath(cache, hv_string * ".csv");

    # if file exists, skip
    if !isfile(outp_file)
        h,v = parse_HV(hv_string);
        lat_mat,lon_mat = load_MODIS(dt, h, v);
        dat_out = DataFrame();
        try
            red_mat = read_nc(FT, path, band[1]);
            nir_mat = read_nc(FT, path, band[2]);
            dim_lon = size(red_mat,1);
            dim_lat = size(red_mat,2);
            (dat_out).lay = ones(Int, dim_lon * dim_lat) * nlayer;
            (dat_out).lat = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).lon = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).red = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).nir = ones(dim_lon * dim_lat) .* -9999;
            for i in 1:dim_lon, j in 1:dim_lat
                _data = view(red_mat,i,j,:);
                _eata = view(nir_mat,i,j,:);
                _mask = (_data .> mm[1]) .* (_data .< mm[2]) .*
                        (_eata .> mm[1]) .* (_eata .< mm[2]);
                if sum(_mask) > 0
                    (dat_out).lat[dim_lat*(i-1)+j] = lat_mat[i,j];
                    (dat_out).lon[dim_lat*(i-1)+j] = lon_mat[i,j];
                    (dat_out).red[dim_lat*(i-1)+j] = nanmean(_data[_mask]);
                    (dat_out).nir[dim_lat*(i-1)+j] = nanmean(_eata[_mask]);
                end
            end
        catch e
            @warn "An error occurred when reading the dataset, use NaN...";
            @show e;
            (dat_out).lay = ones(Int, 1) * nlayer;
            (dat_out).lat = ones(1) .* -9999;
            (dat_out).lon = ones(1) .* -9999;
            (dat_out).red = ones(1) .* -9999;
            (dat_out).nir = ones(1) .* -9999;
        end

        # save data
        mask = ((dat_out).red .> -1) .* ((dat_out).nir .> -1);
        save_csv!(outp_file, dat_out[mask,:]);
    end

    return nothing
end




function grid_RAW!(
            dt::MOD15A2Hv006LAI{FT},
            nlayer::Int,
            path::String,
            prefix::String,
            band::String,
            cache::String,
            mm::Array{FT,1}
) where {FT<:AbstractFloat}
    # transform the data to CSV file
    pos_start = findfirst(prefix, path);
    hv_string = path[pos_start[1]:end];
    outp_file = joinpath(cache, hv_string * ".csv");

    # if file exists, skip
    if !isfile(outp_file)
        h,v = parse_HV(hv_string);
        lat_mat,lon_mat = load_MODIS(dt, h, v);
        dat_out = DataFrame();
        try
            lai_mat = read_nc(FT, path, band);
            dim_lon = size(lai_mat,1);
            dim_lat = size(lai_mat,2);
            (dat_out).lay = ones(Int, dim_lon * dim_lat) * nlayer;
            (dat_out).lat = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).lon = ones(dim_lon * dim_lat) .* -9999;
            (dat_out).lai = ones(dim_lon * dim_lat) .* -9999;
            for i in 1:dim_lon, j in 1:dim_lat
                _data = view(lai_mat,i,j,:);
                _mask = (_data .> mm[1]) .* (_data .< mm[2]);
                if sum(_mask) > 0
                    (dat_out).lat[dim_lat*(i-1)+j] = lat_mat[i,j];
                    (dat_out).lon[dim_lat*(i-1)+j] = lon_mat[i,j];
                    (dat_out).lai[dim_lat*(i-1)+j] = nanmean(_data[_mask]);
                end
            end
        catch e
            @warn "An error occurred when reading the dataset, use NaN...";
            @show e;
            (dat_out).lay = ones(Int, 1) * nlayer;
            (dat_out).lat = ones(1) .* -9999;
            (dat_out).lon = ones(1) .* -9999;
            (dat_out).lai = ones(1) .* -9999;
        end

        # save data
        mask = ((dat_out).lai .> -1);
        save_csv!(outp_file, dat_out[mask,:]);
    end

    return nothing
end




function grid_RAW!(
            dt::AbstractUngriddedData{FT},
            params::Array{Any,1}
) where {FT<:AbstractFloat}
    # run the gridding process
    @info "Gridding RAW data..."
    @showprogress for param in params
        grid_RAW!(param);
    end

    return nothing
end




function grid_RAW!(
            dt::AbstractUngriddedData{FT},
            params::Array{Any,1},
            nthread::Int
) where {FT<:AbstractFloat}
    # create threads
    dynamic_workers!(nthread);

    # run the gridding process
    @info "Gridding RAW data..."
    @showprogress pmap(grid_RAW!, params);

    return nothing
end
=#
