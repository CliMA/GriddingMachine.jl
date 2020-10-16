###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    load_LUT(dt::AbstractDataset{FT}) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             res_g::String,
             res_t::String) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             year::Int,
             res_g::String,
             res_t::String) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             file::String,
             format::AbstractFormat,
             label::String,
             res_t::String,
             rev_lat::Bool,
             var_name::String,
             var_attr::Dict{String,String}) where {FT<:AbstractFloat}

Load look up table and return the struct, given
- `dt` Dataset type, subtype of [`AbstractDataset`](@ref)
- `year` Which year
- `res_g` Resolution in degree
- `res_t` Resolution in time
- `file` File name to read, useful to read local files
- `format` Dataset format from [`AbstractFormat`](@ref)
- `label` Variable label in dataset, e.g., var name in .nc files, band numer in
    .tif files
- `rev_lat` Whether latitude is stored reversely in the dataset, e.g., 90 to
    -90. If true, mirror the dataset on latitudinal direction
- `var_name` Variable name of [`GriddedDataset`](@ref)
- `var_attr` Variable attributes of [`GriddedDataset`](@ref)

Note that the artifact for GPP is about
- `500` MB for 0.2 degree resolution (5^2 * 360*180*46)
- `2600` MB for 0.083 degree resolution (12^2 * 360*180*46)
"""
function load_LUT(dt::AbstractDataset{FT}) where {FT<:AbstractFloat}
    _fn, _fmt, _lab, _res, _rev, _vn, _va = query_LUT(dt);
    return load_LUT(dt, _fn, _fmt, _lab, _res, _rev, _vn, _va)
end




function load_LUT(
            dt::AbstractDataset{FT},
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _fn, _fmt, _lab, _res, _rev, _vn, _va = query_LUT(dt, res_g, res_t);
    return load_LUT(dt, _fn, _fmt, _lab, _res, _rev, _vn, _va)
end




function load_LUT(
            dt::AbstractDataset{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _fn, _fmt, _lab, _res, _rev, _vn, _va = query_LUT(dt, year, res_g, res_t);
    return load_LUT(dt, _fn, _fmt, _lab, _res, _rev, _vn, _va)
end




function load_LUT(
            dt::LAIMonthlyMean{FT},
            file::String,
            format::FormatNC,
            label::String,
            res_t::String,
            rev_lat::Bool,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    _data = FT.(ncread(file, label));
    data  = similar(_data);

    for _mon in 1:7
        data[:,:,_mon] .= _data[:,:,_mon+5];
    end
    for _mon in 8:12
        data[:,:,_mon] .= _data[:,:,_mon-7];
    end

    return GriddedDataset{FT}(data     = data    ,
                              res_time = res_t   ,
                              dt       = dt      ,
                              var_name = var_name,
                              var_attr = var_attr)
end




function load_LUT(
            dt::LandMaskERA5{FT},
            file::String,
            format::FormatNC,
            label::String,
            res_t::String,
            rev_lat::Bool,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    # land mask used is specified, cannot be used directly
    _data   = FT.(ncread(file, label));
    _data .+= 32766;
    _data ./= 65533;

    return GriddedDataset{FT}(data     = _data   ,
                              res_time = res_t   ,
                              dt       = dt      ,
                              var_name = var_name,
                              var_attr = var_attr)
end




function load_LUT(
            dt::AbstractDataset{FT},
            file::String,
            format::FormatNC,
            label::String,
            res_t::String,
            rev_lat::Bool,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    _data = FT.(ncread(file, label));

    # reverse latitude
    if rev_lat
        _data = _data[:,end:-1:1,:];
    end

    # convert data to 3D array
    if length(size(_data)) == 2
        data = cat(_data; dims=3);
    else
        data = _data;
    end

    return GriddedDataset{FT}(data     = data    ,
                              res_time = res_t   ,
                              dt       = dt      ,
                              var_name = var_name,
                              var_attr = var_attr)
end




function load_LUT(
            dt::AbstractDataset{FT},
            file::String,
            format::FormatTIFF,
            label::Int,
            res_t::String,
            rev_lat::Bool,
            var_name::String,
            var_attr::Dict{String,String}
) where {FT<:AbstractFloat}
    _tiff = ArchGDAL.read(file);
    _band = ArchGDAL.getband(_tiff, label);
    _data = convert(Matrix{FT}, ArchGDAL.read(_band));

    # reverse latitude
    if rev_lat
        _data = _data[:,end:-1:1,:];
    end

    # filter data
    _data ./= 100;
    data = cat(_data; dims=3);

    return GriddedDataset{FT}(data     = data    ,
                              res_time = res_t   ,
                              dt       = dt      ,
                              var_name = var_name,
                              var_attr = var_attr)
end




function load_LUT(dt::VcmaxOptimalCiCa{FT}) where {FT<:AbstractFloat}
    _Vcmax = FT.(ncread(joinpath(artifact"leaf_traits_2X_1Y",
                                 "vcmax_optimal_cica_2X_1Y.nc"),
                        "vcmax"));

    # note that lat of dataset does not start from -90 and end from 90
    # store the data into a new data array
    _NewVM::Array{FT,3} = ones(FT, (720,360,1)) .* -999;
    lat_array = collect(FT,83.75:-0.5:-55.75);
    for i in eachindex(lat_array)
        lat_indx = lat_ind(lat_array[i]; res = FT(0.5));
        _NewVM[:,lat_indx,1] .= _Vcmax[:,i];
    end
    _varn = "Vcmax";
    _vara = Dict("longname" => "Maximal carboxylation rate at 25 °C",
                 "units"    => "μmol m⁻² s⁻¹")

    return GriddedDataset{FT}(data     = _NewVM ,
                              res_lat  = FT(0.5),
                              res_lon  = FT(0.5),
                              res_time = "1Y"   ,
                              dt       = dt     ,
                              var_name = _varn  ,
                              var_attr = _vara  )
end
