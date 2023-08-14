#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#     2023-May-17: add coverage support
#     2023-May-17: add step to visualize reprocessed data before saving
#
#######################################################################################################################################################################################################
"""

    reprocess_data!(
                dict::Dict;
                file_name_function::Union{Function,Nothing} = nothing,
                data_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])],
                std_scaling_functions::Vector = [nothing for _i in eachindex(dict["VARIABLE_SETTINGS"])],
                data_masking_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])],
                std_masking_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])])

Reprocess the data to use in GriddingMachine artifacts, given
- `dict` JSON dict
- `file_name_function` Function to find file
- `data_scaling_functions` Functions to scale data
- `std_scaling_functions` Functions to scale std
- `data_masking_functions` Functions to mask data to NaN
- `std_masking_functions` Functions to mask std to NaN

"""
function reprocess_data!(
            folder_path::String,
            dict::Dict;
            file_name_function::Union{Function,Nothing} = nothing,
            data_scaling_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])],
            std_scaling_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])],
            data_masking_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])],
            std_masking_functions::Vector = [nothing for _i in eachindex(dict["INPUT_VAR_SETS"])])
    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);

    _dict_file = dict["INPUT_MAP_SETS"];
    _dict_grid = dict["GRIDDINGMACHINE"];
    _dict_vars = dict["INPUT_VAR_SETS"];
    _dict_outv = dict["OUTPUT_VAR_ATTR"];
    _dict_refs = dict["OUTPUT_REF_ATTR"];
    _dict_stds = "INPUT_STD_SETS" in keys(dict) ? dict["INPUT_STD_SETS"] : nothing;

    # determine if there is any information for years
    _years = _dict_grid["YEARS"];
    _files = [];
    if isnothing(_years)
        push!(_files, _dict_file["FOLDER"] * "/" * _dict_file["FILE_NAME_PATTERN"]);
    else
        for _year in _years
            push!(_files, _dict_file["FOLDER"] * "/" * 
                (file_name_function  == "" || file_name_function === nothing ? _dict_file["FILE_NAME_PATTERN"] : 
                replace(_dict_file["FILE_NAME_PATTERN"], "XXXXXXXX" => file_name_function(_year))));
        end;
    end;

    _reprocessed_data = [];
    _reprocessed_std = [];

    # iterate through the files
    _i_years = (isnothing(_years) ? [1] : eachindex(_years));
    for _i_year in _i_years
        # determine whether to skip based on the tag
        _tag = (isnothing(_years) ? griddingmachine_tag(dict) : griddingmachine_tag(dict, _years[_i_year]));
        _reprocessed_file = "$(folder_path)/$(_tag).nc";

        if isfile(_reprocessed_file)
            @info "File $(_reprocessed_file) exists already";
            continue;
            #=_msg = "Do you still want to reprocess the data? Type Y/y or N/n to continue > ";
            if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
                @info "Skipping...";
                continue;
            end;=#
        else
            @info "File $(_reprocessed_file) does not exist, reprocessing...";
        end;
        
        # read the data
        _file = _files[_i_year]
        if length(_dict_vars) == 1
            _reprocessed_data = read_data(
                        _file,
                        _dict_vars[1],
                        _dict_file["FORMAT"],
                        [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]],
                        _dict_grid["LAT_LON_RESO"];
                        coverage = _dict_file["COVERAGE"],
                        scaling_function = data_scaling_functions[1],
                        masking_function = data_masking_functions[1],
                        is_center = _dict_file["IS_CENTER"]);
            _reprocessed_std = if !isnothing(_dict_stds)
                read_data(
                        _file,
                        _dict_stds[1],
                        _dict_file["FORMAT"],
                        [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]],
                        _dict_grid["LAT_LON_RESO"];
                        coverage = _dict_file["COVERAGE"],
                        scaling_function = std_scaling_functions[1],
                        masking_function = std_masking_functions[1],
                        is_center = _dict_file["IS_CENTER"])
            else
                similar(_reprocessed_data) .* NaN
            end;
        else
            _reprocessed_data = ones(Float64, 360 * _dict_grid["LAT_LON_RESO"], 180 * _dict_grid["LAT_LON_RESO"], length(_dict_vars));
            _reprocessed_std = ones(Float64, 360 * _dict_grid["LAT_LON_RESO"], 180 * _dict_grid["LAT_LON_RESO"], length(_dict_vars)) .* NaN;
            for _i_var in eachindex(_dict_vars)
                _reprocessed_data[:,:,_i_var] = read_data(
                        _file,
                        _dict_vars[_i_var],
                        _dict_file["FORMAT"],
                        [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]],
                        _dict_grid["LAT_LON_RESO"];
                        coverage = _dict_file["COVERAGE"],
                        scaling_function = data_scaling_functions[_i_var],
                        masking_function = data_masking_functions[_i_var],
                        is_center = _dict_file["IS_CENTER"]);
                if !isnothing(_dict_stds)
                    _reprocessed_std[:,:,_i_var] = read_data(
                        _file,
                        _dict_stds[_i_var],
                        _dict_file["FORMAT"],
                        [_dict_file["FLIP_LAT"],_dict_file["FLIP_LON"]],
                        _dict_grid["LAT_LON_RESO"];
                        coverage = _dict_file["COVERAGE"],
                        scaling_function = std_scaling_functions[_i_var],
                        masking_function = std_masking_functions[_i_var],
                        is_center = _dict_file["IS_CENTER"]);
                end;
            end;
        end;

        #Check if file is land only and if processed data falls on land
        if _dict_file["LAND_ONLY"] && !check_land_mask(_reprocessed_data; division = _dict_grid["LAT_LON_RESO"])
            @warn "The dataset is set to be land only, but not all values are on land."
        end;

        #ask user whether to save file
        #=_msg = "Do you want to save the data? Type Y/y or N/n to continue > ";
        _save_data = (verified_input(_msg, uppercase, _jdg_1) in ["Y", "YES"]);=#

        # save the file
        #if _save_data
            _var_attr::Dict{String,String} = merge(_dict_outv,_dict_refs);
            _dim_names = length(size(_reprocessed_std)) == 3 ? ["lon", "lat", "ind"] : ["lon", "lat"];
            save_nc!(_reprocessed_file, "data", _reprocessed_data, _var_attr; var_dims = _dim_names);
            append_nc!(_reprocessed_file, "std", _reprocessed_std, _var_attr, _dim_names);
            @info "File saved";
        #=else
            @info "File not saved";
        end;=#

    end;

    # add change logs based on the JSON file
    #=
    - Add uncertainty (filled with NaN)
    - Make the map to global scale (fill with NaN)
    - Reformatted from GeoTIFF or binary to NetCDF **
    - Latitude and Longitude re-oriented to from South to North and from West to East
    - Data scaling removed (from log(x), exp(x), or kx+b to x)
    - Data regridded to coarser resolution by averaging all data falling into the new grid **
    - Unit standardization **
    - Reorder the dimensions to (lon, lat, ind)
    - Unrealistic values to NaN **
    =#
    # _count = 0;
    # push!()

    return _reprocessed_data, _reprocessed_std #nothing
end;

"""

    check_land_mask(data::Array{FT,N}; division::Int = 1, threshold::Number = 0.01) where {FT,N}

Check if data falls on land
- `data` Data to check
- `division` Spatial resolution of the land mask is 1/division degree
- `threshold` Threshold of land mask

"""
function check_land_mask(data::Array{FT,N}; division::Int = 1, threshold::Number = 0.01) where {FT,N}
    @assert N in [2, 3] "data must be 2D or 3D";
    @assert size(data,1) == division * 360 "data must be 360 * division in longitude";
    @assert size(data,2) == division * 180 "data must be 180 * division in latitude";

    # read land mask data from GriddingMachine if the data is not yet loaded into memory
    LAND_MASK = load("src/processer/land_mask.jld2", "LAND_MASK")

    # regrid land mask data to the same resolution as data
    _land_mask = regrid(LAND_MASK, division);

    # filter out NaNs in data based on land mask threshold
    # replace NaNs in data with replacement
    if N == 2
        _nan_mask = isnan.(data) .|| (_land_mask .>= threshold);
        return !(false in _nan_mask);
    end;
    if N == 3
        for _i in axes(data, 3)
            _nan_mask = isnan.(data[:,:,_i]) .|| (_land_mask .>= threshold);
            if (false in _nan_mask) return false; end;
        end;
        return true;
    end;

    return true;
end
