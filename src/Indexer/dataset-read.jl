function read_dataset end

function _dataset_file(tf::String)
    isfile(tf) && return tf
    endswith(lowercase(tf), ".nc") && error("The local dataset file $tf does not exist")
    downloaded = download_dataset!(tf)
    isfile(downloaded) || error("The dataset file $downloaded does not exist")
    return downloaded
end

function _dataset_variable(fpath::String; raw_data::Bool = false, read_std::Bool = false)
    variables = read_varnames(fpath)
    read_std && return "std" in variables ? "std" : nothing
    return raw_data && "raw_data" in variables ? "raw_data" : "data"
end

function _site_indices(fpath::String, lat::Number, lon::Number)
    (_, sizes) = read_dims(fpath, "lat")
    resolution = 180 / sizes[1]
    return lon_ind(lon, resolution), lat_ind(lat, resolution)
end

"""Read an entire local NetCDF file or a catalog dataset tag."""
function read_dataset(tf::String; raw_data::Bool = false, read_std::Bool = false)
    fpath = _dataset_file(tf)
    variable = _dataset_variable(fpath; raw_data, read_std)
    isnothing(variable) && return nothing
    return read_nc(fpath, variable)
end

"""Read one 1-based cycle from a local NetCDF file or catalog dataset tag."""
function read_dataset(tf::String, cyc::Int; raw_data::Bool = false, read_std::Bool = false)
    fpath = _dataset_file(tf)
    variable = _dataset_variable(fpath; raw_data, read_std)
    isnothing(variable) && return nothing
    return read_nc(fpath, variable, cyc)
end

"""Read all cycles at the grid cell containing `(lat, lon)`."""
function read_dataset(tf::String, lat::Number, lon::Number; raw_data::Bool = false, read_std::Bool = false)
    fpath = _dataset_file(tf)
    variable = _dataset_variable(fpath; raw_data, read_std)
    isnothing(variable) && return nothing
    ilon, ilat = _site_indices(fpath, lat, lon)
    return read_nc(fpath, variable, ilon, ilat)
end

"""Read one cycle at the grid cell containing `(lat, lon)`."""
function read_dataset(tf::String, lat::Number, lon::Number, cyc::Int; raw_data::Bool = false, read_std::Bool = false)
    fpath = _dataset_file(tf)
    variable = _dataset_variable(fpath; raw_data, read_std)
    isnothing(variable) && return nothing
    ilon, ilat = _site_indices(fpath, lat, lon)
    return read_nc(fpath, variable, ilon, ilat, cyc)
end

"""Compatibility alias retained for code written against GriddingMachine 0.4."""
const read_LUT = read_dataset
