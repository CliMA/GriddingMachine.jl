###############################################################################
#
# Regrid the data to lower resolutions
#
###############################################################################
"""
    regrid_LUT(ds::AbstractDataset{FT},
               zoom::Int;
               nan_weight::Bool=false
    ) where {FT<:AbstractFloat}

Regrid the data from high to low resolution and return the struct, given
- `ds` [`GriddedDataset`](@ref) type struct
- `zoom` Integer geophysical zoom factor (>=2)
- `nan_weight` Optional. If true, assuming nan = 0; if false, neglecting it.
"""
function regrid_LUT(
            ds::GriddedDataset{FT},
            zoom::Int;
            nan_weight::Bool=false
) where {FT<:AbstractFloat}
    # unpack data
    @unpack data = ds;

    # create a matrix to store the sum and a matrix to store the counts
    mat_size  = (Int(size(data,1)/zoom), Int(size(data,2)/zoom), size(data,3));
    mat_data  = zeros(FT , mat_size);
    mat_count = zeros(Int, mat_size);

    # loop through the datasets
    for _lon_i in 1:mat_size[1], _lat_i in 1:mat_size[2]
        # select a region to map into target matrix
        _lon_j = (_lon_i-1)*zoom+1 : _lon_i*zoom;
        _lat_j = (_lat_i-1)*zoom+1 : _lat_i*zoom;

        # re-mapping the data per layer
        for _layer in 1:mat_size[3]
            for _lon_x in _lon_j, _lat_x in _lat_j
                _tmp_data = data[_lon_x, _lat_x, _layer];
                if !isnan(_tmp_data)
                    mat_data[ _lon_i, _lat_i, _layer] += _tmp_data;
                    mat_count[_lon_i, _lat_i, _layer] += 1;
                elseif nan_weight
                    mat_count[_lon_i, _lat_i, _layer] += 1;
                end
            end
        end
    end

    # refactor the matrix by taking the mean
    mat_data ./= mat_count;

    return GriddedDataset{FT}(data     = mat_data   ,
                              res_time = ds.res_time,
                              var_name = ds.var_name,
                              var_attr = ds.var_attr)
end
