
function read_dataset end;

"""

    read_dataset(tf::String; raw_data::Bool = false, read_std::Bool = false)

Read the entire dataset from the given file name or tag name, given
- `tf` local file name (ending with `.nc`) or remote tag name
- `raw_data` if true, read the `raw_data` variable from the dataset file (if exists, otherwise read `data` variable)
- `read_std` if true, read the `std` variable from the dataset file (if exists, otherwise return `nothing`)

"""
read_dataset(tf::String; raw_data::Bool = false, read_std::Bool = false) = (
    # if the file end with .nc, it is a local file
    fpath = endswith(tf, ".nc") ? tf : download_dataset!(tf);
    if !isfile(fpath)
        error("The dataset file $fpath does not exist!");
    end;

    # read std mode
    if read_std
        return ("std" in varname_nc(fpath)) ? read_nc(fpath, "std") : nothing
    end;

    # read raw data mode
    if raw_data && ("raw_data" in varname_nc(fpath))
        return read_nc(fpath, "raw_data")
    end;

    return read_nc(fpath, "data");
);

"""

    read_dataset(tf::String, cyc::Int; raw_data::Bool = false, read_std::Bool = false)

Read the dataset at the given cycle, given
- `tf` local file name (ending with `.nc`) or remote tag name
- `cyc` cycle index (1-based)
- `raw_data` if true, read the `raw_data` variable from the dataset file (if exists, otherwise read `data` variable)
- `read_std` if true, read the `std` variable from the dataset file (if exists, otherwise return `nothing`)

"""
read_dataset(tf::String, cyc::Int; raw_data::Bool = false, read_std::Bool = false) = (
    # if the file end with .nc, it is a local file
    fpath = endswith(tf, ".nc") ? tf : download_dataset!(tf);
    if !isfile(fpath)
        error("The dataset file $fpath does not exist!");
    end;

    # read std mode
    if read_std
        return ("std" in varname_nc(fpath)) ? read_nc(fpath, "std", cyc) : nothing
    end;

    # read raw data mode
    if raw_data && ("raw_data" in varname_nc(fpath))
        return read_nc(fpath, "raw_data", cyc)
    end;

    return read_nc(fpath, "data", cyc);
);

"""

    read_dataset(tf::String, lat::Number, lon::Number; raw_data::Bool = false, read_std::Bool = false)

Read the dataset value at the site level, given
- `tf` local file name (ending with `.nc`) or remote tag name
- `lat` latitude of the site
- `lon` longitude of the site
- `raw_data` if true, read the `raw_data` variable from the dataset file (if exists, otherwise read `data` variable)
- `read_std` if true, read the `std` variable from the dataset file (if exists, otherwise return `nothing`)

"""
read_dataset(tf::String, lat::Number, lon::Number; raw_data::Bool = false, read_std::Bool = false) = (
    # if the file end with .nc, it is a local file
    fpath = isfile(tf) ? tf : download_dataset!(tf);
    if !isfile(fpath)
        error("The dataset file $fpath does not exist!");
    end;

    # determine the resolution
    (_,sizes) = size_nc(fpath, "lat");
    res = 180 / sizes[1];

    # get the index of lat and lon
    ilat = lat_ind(lat, res);
    ilon = lon_ind(lon, res);

    # read std mode
    if read_std
        return ("std" in varname_nc(fpath)) ? read_nc(fpath, "std", ilon, ilat) : nothing
    end;

    # read raw data mode
    if raw_data && ("raw_data" in varname_nc(fpath))
        return read_nc(fpath, "raw_data", ilon, ilat)
    end;

    return read_nc(fpath, "data", ilon, ilat)
);

"""

    read_dataset(tf::String, lat::Number, lon::Number, cyc::Int; raw_data::Bool = false, read_std::Bool = false)

Read the dataset value at the site level and given cycle, given
- `tf` local file name (ending with `.nc`) or remote tag name
- `lat` latitude of the site
- `lon` longitude of the site
- `cyc` cycle index (for example, 1:12 for January to December, users need to know the dimensions a priori)
- `raw_data` if true, read the `raw_data` variable from the dataset file (if exists, otherwise read `data` variable)
- `read_std` if true, read the `std` variable from the dataset file (if exists, otherwise return `nothing`)

"""
read_dataset(tf::String, lat::Number, lon::Number, cyc::Int; raw_data::Bool = false, read_std::Bool = false) = (
    # if the file end with .nc, it is a local file
    fpath = isfile(tf) ? tf : download_dataset!(tf);
    if !isfile(fpath)
        error("The dataset file $fpath does not exist!");
    end;

    # determine the resolution
    (_,sizes) = size_nc(fpath, "lat");
    res = 180 / sizes[1];

    # get the index of lat and lon
    ilat = lat_ind(lat, res);
    ilon = lon_ind(lon, res);

    # read std mode
    if read_std
        return ("std" in varname_nc(fpath)) ? read_nc(fpath, "std", ilon, ilat, cyc) : nothing
    end;

    # read raw data mode
    if raw_data && ("raw_data" in varname_nc(fpath))
        return read_nc(fpath, "raw_data", ilon, ilat, cyc)
    end;

    return read_nc(fpath, "data", ilon, ilat, cyc)
);


""" read_LUT() is an alias of read_dataset() """
read_LUT = read_dataset;
