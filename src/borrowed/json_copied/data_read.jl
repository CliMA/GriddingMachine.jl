#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#     2023-May-17: add coverage support
#
#######################################################################################################################################################################################################
"""

    read_data_2d(data::Array, ind::Int, dict::Dict, flipping::Vector, resox::Int; coverage::Union{String,Vector} = "GLOBAL", scaling_function::Union{Function,Nothing} = nothing)

Return formatted 2D data, given
- `data` Input 3D data
- `ind` Index for 3rd dimension
- `dict` Dict about the data format
- `flipping` Whether to flip latitude and longitude
- `resox` Spatial resolution (N means 1/N °)
- `coverage` The coverage of input map
- `scaling_function` Scaling function that to apply
- `masking_function` Masking function that to apply
- `is_center` Whether the data is at center

"""
function read_data_2d(data::Array, ind::Int, dict::Dict, flipping::Vector, resox::Int; 
                        coverage::Union{String,Vector} = "GLOBAL",
                        scaling_function::Union{Function,Nothing} = nothing, 
                        masking_function::Union{Function,Nothing} = nothing, 
                        is_center::Bool = true)

    # read the layer based on the index orders
    if isnothing(dict["INDEX_AXIS_INDEX"])
        if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 2
            _eata = data;
        else
            _eata = data';
        end;
    else
        if dict["INDEX_AXIS_INDEX"] == 3
            if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 2
                _eata = data[:,:,ind];
            else
                _eata = data[:,:,ind]';
            end;
        elseif dict["INDEX_AXIS_INDEX"] == 2
            if dict["LONGITUDE_AXIS_INDEX"] == 1 && dict["LATITUDE_AXIS_INDEX"] == 3
                _eata = data[:,ind,:];
            else
                _eata = data[:,ind,:]';
            end;
        elseif dict["INDEX_AXIS_INDEX"] == 1
            if dict["LONGITUDE_AXIS_INDEX"] == 2 && dict["LATITUDE_AXIS_INDEX"] == 3
                _eata = data[ind,:,:];
            else
                _eata = data[ind,:,:]';
            end;
        end;
    end;

    # flip the lat and lons
    _fata = flipping[1] ? _eata[:,end:-1:1] : _eata;
    _gata = flipping[2] ? _fata[end:-1:1,:] : _fata;

    # add a masking function
    _hata = isnothing(masking_function) ? _gata : masking_function.(_gata);

    # add a scaling function
    _hata = isnothing(scaling_function) ? _hata : scaling_function.(_hata);

    #change from edge to center if needed
    if !is_center
        _data = zeros(Float64, resox * 360, resox * 180);
        for lon in range(1, resox * 360)
            for lat in range(1, resox * 180)
                _data[lon, lat] = (_hata[lon, lat] + _hata[lon+1, lat] + _hata[lon, lat+1] + _hata[lon+1, lat+1])/4;
            end
        end
        _hata = _data;
    end

    # if coverage is GLOBAL, return the data as it is
    if coverage == "GLOBAL"
        return _hata
    end;

    # if the coverage is not global, expand the data
    _data = zeros(Float64, resox * 360, resox * 180) .* NaN64;
    _reso = 1 / resox;
    _lats = (-90+_reso/2):_reso:90;
    _lons = (-180+_reso/2):_reso:180;
    _ilats = (coverage[1] .<= _lats .<= coverage[2]);
    _ilons = (coverage[3] .<= _lons .<= coverage[4]);
    _data[_ilons,_ilats] .= _hata;
    
    return _data
end


#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: move function from GriddingMachineDatasets
#     2023-May-17: add coverage support
#
#######################################################################################################################################################################################################
"""

    read_data(filename::String, dict::Dict, flipping::Vector, resox::Int; coverage::Union{String,Vector} = "GLOBAL", scaling_function::Union{Function,Nothing} = nothing)

Return the formatted data, given
- `filename` File to read
- `dict` Dict about the data format
- `flipping` Whether to flip latitude and longitude
- `resox` Spatial resolution (N means 1/N °)
- `coverage` The coverage of input map
- `scaling_function` Scaling function that to apply
- `masking_function` Masking function that to apply
- `is_center` Whether the data is at center

"""
function read_data(filename::String, dict::Dict, flipping::Vector, resox::Int;
                    coverage::Union{String,Vector} = "GLOBAL", 
                    scaling_function::Union{Function,Nothing} = nothing, 
                    masking_function::Union{Function,Nothing} = nothing, 
                    is_center::Bool = true)

    _data = read_nc(filename, dict["DATA_NAME"]);

    # rotate the data if necessary
    if isnothing(dict["INDEX_AXIS_INDEX"])
        return read_data_2d(_data, 1, dict, flipping, resox;
                            coverage = coverage, 
                            scaling_function = scaling_function, 
                            masking_function = masking_function,
                            is_center = is_center)
    else
        _eata = zeros(Float64, resox * 360, resox * 180, size(_data, dict["INDEX_AXIS_INDEX"]));
        for _ind in axes(_data, dict["INDEX_AXIS_INDEX"])
            _eata[:,:,_ind] .= read_data_2d(_data, _ind, dict, flipping, resox;
                                            coverage = coverage, 
                                            scaling_function = scaling_function, 
                                            masking_function = masking_function,
                                            is_center = is_center);
        end;
        
        return _eata
    end;
end
