###############################################################################
#
# Save the dataset
#
###############################################################################
"""
    save_LUT(ds::GriddedDataset{FT},
             filename::String) where {FT<:AbstractFloat}
    save_LUT(data::Array{FT,2},
             filename::String) where {FT<:AbstractFloat}
    save_LUT(data::Array{FT,3},
             filename::String,
             var_name::String,
             var_attr::Dict{String,String}) where {FT<:AbstractFloat}

Save the dataset, given
- `ds` [`GriddedDataset`](@ref) type struct
- `filename` NC file name to save to
- `data` Temporaty data
- `var_name` Variable name in nc file
- `var_attr` Variable attributes in nc file

Note that `save_LUT(data, filename)` is designed to use with temporaty data
    only, be cautious when using this function.
"""
function save_LUT(
            ds::GriddedDataset{FT},
            filename::String
) where {FT<:AbstractFloat}
    # unpack parameters
    @unpack data, res_lat, res_lon, var_name, var_attr = ds;

    # calculate lat and lon from dataset size
    _lat = collect(FT, ( -90+res_lat/2):res_lat:( 90-res_lat/2));
    _lon = collect(FT, (-180+res_lon/2):res_lon:(180-res_lon/2));
    _cyc = collect(Int, 1:size(data,3));

    # attributes
    latatts = Dict("longname" => "Latitude" , "units" => "°");
    lonatts = Dict("longname" => "Longitude", "units" => "°");
    cycatts = Dict("longname" => "Cycle"    , "units" => "-");

    # create nc file
    nccreate(filename, var_name,
             "lon"  , _lon, lonatts,
             "lat"  , _lat, latatts,
             "cycle", _cyc, cycatts,
             atts = var_attr);
    ncwrite(data, filename, var_name);

    return nothing
end




function save_LUT(
            data::Array{FT,2},
            filename::String
) where {FT<:AbstractFloat}
    dims    = size(data);
    res_lat = 180/dims[2];
    res_lon = 360/dims[1];

    # calculate lat and lon from dataset size
    _lat = collect(FT, ( -90+res_lat/2):res_lat:( 90-res_lat/2));
    _lon = collect(FT, (-180+res_lon/2):res_lon:(180-res_lon/2));

    # attributes
    latatts = Dict("longname" => "Latitude" , "units" => "°");
    lonatts = Dict("longname" => "Longitude", "units" => "°");
    varatts = Dict("longname" => "Variable" , "units" => "-");

    # create nc file
    nccreate(filename, "Var",
             "lon"  , _lon, lonatts,
             "lat"  , _lat, latatts,
             atts = varatts);
    ncwrite(data, filename, "Var");

    return nothing
end




function save_LUT(
            data::Array{FT,3},
            filename::String,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    dims    = size(data);
    res_lat = 180/dims[2];
    res_lon = 360/dims[1];

    # calculate lat and lon from dataset size
    _lat = collect(FT, ( -90+res_lat/2):res_lat:( 90-res_lat/2));
    _lon = collect(FT, (-180+res_lon/2):res_lon:(180-res_lon/2));
    _cyc = 1:dims[3];

    # attributes
    latatts = Dict("longname" => "Latitude" , "units" => "°");
    lonatts = Dict("longname" => "Longitude", "units" => "°");
    cycatts = Dict("longname" => "Cycle"    , "units" => "-");

    # create nc file
    nccreate(filename, var_name,
             "lon"  , _lon, lonatts,
             "lat"  , _lat, latatts,
             "cycle", _cyc, cycatts,
             atts = var_attr);
    ncwrite(data, filename, var_name);

    return nothing
end
