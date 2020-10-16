###############################################################################
#
# Regrid the data to lower resolutions
#
###############################################################################
"""
    mask_LUT!(ds::GriddedDataset, default::Number)
    mask_LUT!(ds::GriddedDataset, lims::Array)

Filter out the unrealistic values from the dataset, given
- `ds` [`GriddedDataset`](@ref) type struct
- `default` Optional. Default value to replace NaNs
- `lims` Lower and upper limits for the dataset
"""
function mask_LUT!(ds::GriddedDataset, default::Number=-9999)
    @unpack data = ds;

    # to avoid memory overflow, filter the data per line
    _size = size(data,1) * size(data,2) * size(data,3);
    if _size < 1e7
        _mask = isnan.(data);
        data[_mask] .= default;
    else
        println("Replacing NaN with unrealistic values...");
        @showprogress for i in 1:size(data,2)
            _mask = isnan.(view(data,:,i,:));
            view(data,:,i,:)[_mask] .= default;
        end
    end

    return nothing
end




function mask_LUT!(ds::GriddedDataset, lims::Array)
    @unpack data = ds;
    _lower, _upper = lims;

    # to avoid memory overflow, filter the data per line
    _size = size(data,1) * size(data,2) * size(data,3);
    if _size < 1e7
        _mask = (_lower .<= data .<= _upper);
        data[.!_mask] .= NaN;
    else
        println("Replacing unrealistic values with NaN...");
        @showprogress for i in 1:size(data,2)
            _mask = (_lower .<= view(data,:,i,:) .<= _upper);
            view(data,:,i,:)[.!_mask] .= NaN;
        end
    end

    return nothing
end
