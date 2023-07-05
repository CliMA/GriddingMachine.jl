using Random;

include("/home/exgu/GriddingMachine.jl/src/borrowed/EmeraldIO.jl");

Random.seed!(1234);

lon = 361
lat = 181
ind = 12

_lons = collect(0:1:360) .- 180;
_lats = collect(0:1:180) .- 90;
_inds  = collect(1:ind);

order = [["lon", "lat", "ind"], ["lon", "ind", "lat"], ["lat", "lon", "ind"], ["lat", "ind", "lon"], ["ind", "lon", "lat"], ["ind", "lat", "lon"]];

#data on edge rather than center
edge = rand(Float64, lon, lat, ind);
save_nc!("test/nc_files/edge.nc", "edge", edge, Dict("description" => "Random data"), order[1]);

lon = 360;
lat = 180;
_lons = collect(1/2:1:360) .- 180;
_lats = collect(1/2:1:180) .- 90;

#desired data
lon_lat_ind = zeros(Float64, lon, lat, ind);

for i in range(1, lon)
    for j in range(1, lat)
        for k in range(1, ind)
            lon_lat_ind[i, j, k] = (edge[i, j, k]+edge[i+1, j, k]+edge[i, j+1, k]+edge[i+1, j+1, k])/4;
        end
    end
end

save_nc!("test/nc_files/lon_lat_ind.nc", "lon_lat_ind", lon_lat_ind, Dict("description" => "Random data, correct format"), order[1]);

#data with orders changed
lon_ind_lat = zeros(Float64, lon, ind, lat);
lat_lon_ind = zeros(Float64, lat, lon, ind);
lat_ind_lon = zeros(Float64, lat, ind, lon);
ind_lon_lat = zeros(Float64, ind, lon, lat);
ind_lat_lon = zeros(Float64, ind, lat, lon);

#data with lon or lat flipped
lonf_lat_ind = zeros(Float64, lon, lat, ind);
lon_latf_ind = zeros(Float64, lon, lat, ind);

#data with scaling
lin_scale = zeros(Float64, lon, lat, ind);
exp_scale = zeros(Float64, lon, lat, ind);

for i in range(1, lon)
    for j in range(1, lat)
        for k in range(1, ind)
            lon_ind_lat[i, k, j] = lon_lat_ind[i, j, k];
            lat_lon_ind[j, i, k] = lon_lat_ind[i, j, k];
            lat_ind_lon[j, k, i] = lon_lat_ind[i, j, k];
            ind_lon_lat[k, i, j] = lon_lat_ind[i, j, k];
            ind_lat_lon[k, j, i] = lon_lat_ind[i, j, k];

            lonf_lat_ind[lon+1-i, j, k] = lon_lat_ind[i, j, k];
            lon_latf_ind[i, lat+1-j, k] = lon_lat_ind[i, j, k];

        end
    end
end

map = Dict(["lon", "ind", "lat"] => lon_ind_lat, ["lat", "lon", "ind"] => lat_lon_ind, 
            ["lat", "ind", "lon"] => lat_ind_lon, ["ind", "lon", "lat"] => ind_lon_lat, 
            ["ind", "lat", "lon"] => ind_lat_lon);

lin_scale = lon_lat_ind .* 2;
exp_scale = exp.(lon_lat_ind);

for o in order
    if o == ["lon", "lat", "ind"] continue; end;
    name = o[1]*"_"*o[2]*"_"*o[3];
    path = "test/nc_files/"*name*".nc";
    save_nc!(path, name, map[o], Dict("description" => "Random data"), o);
end

_lons = collect(359.5:-1:0) .- 180;
_lats = collect(1/2:1:180) .- 90;
save_nc!("test/nc_files/lonf_lat_ind.nc", "lonf_lat_ind", lonf_lat_ind, Dict("description" => "Random data"), order[1]);

_lons = collect(1/2:1:360) .- 180;
_lats = collect(179.5:-1:0) .- 90;
save_nc!("test/nc_files/lon_latf_ind.nc", "lon_latf_ind", lon_latf_ind, Dict("description" => "Random data"), order[1]);

_lons = collect(1/2:1:360) .- 180;
_lats = collect(1/2:1:180) .- 90;
save_nc!("test/nc_files/lin_scale.nc", "lin_scale", lin_scale, Dict("description" => "Random data, linearly scaled"), order[1]);
save_nc!("test/nc_files/exp_scale.nc", "exp_scale", exp_scale, Dict("description" => "Random data, exponentially scaled"), order[1]);


#data with global vs partial coverage
lat1 = 31;
lat2 = 170;
partial = lon_lat_ind[:, lat1:lat2, :];
glob = copy(lon_lat_ind);
glob[:, 1:(lat1-1), :] .= NaN;
glob[:, (lat2+1):lat, :] .= NaN;

lat = 140;
_lats = collect(30.5:1:169.5) .- 90;
save_nc!("test/nc_files/partial.nc", "partial", partial, Dict("description" => "Random data, partial"), order[1]);

lat = 180;
_lats = collect(1/2:1:180) .- 90;
save_nc!("test/nc_files/glob.nc", "glob", glob, Dict("description" => "Random data, global"), order[1]);


#data with sep files
same_file = rand(Float64, lon, lat, 2);
file_1 = reshape(same_file[:, :, 1], lon, lat);
file_2 = reshape(same_file[:, :, 2], lon, lat);

save_nc!("test/nc_files/same_file.nc", "same_file", same_file, Dict("description" => "Random data, same file"), order[1]);
save_nc!("test/nc_files/file_1.nc", "same_file", file_1, Dict("description" => "Random data, file 1"), ["lon", "lat"]);
save_nc!("test/nc_files/file_2.nc", "same_file", file_2, Dict("description" => "Random data, file 2"), ["lon", "lat"]);

print("ok");