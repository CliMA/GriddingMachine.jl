"""

    read_tif(file::String, band_number::String)
    read_tif(T, file::String, band_number::String)

Read entire data from GeoTIFF file, given
- `file` Path of the GeoTIFF dataset
- `band_number` Band number to read
- `T` Number type
"""
function read_tif end

read_tif(file::String, band_number::String) = (
    _dset = read(file);

    _fvar = getband(_dset, parse("Int", band_number));

    close(_dset);

    if _fvar === nothing
        @error "Band $(band_number) does not exist in $(file)!";
    end;

    return replace(_fvar, missing=>NaN)
);

read_tif(T, file::String, var_name::String) = T.(read_tif(file, var_name));