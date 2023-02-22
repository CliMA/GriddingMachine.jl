module Blender

using DocStringExtensions: METHODLIST
using PkgUtility: nanmean

export regrid


"""

    expand(data::Matrix{FT}, n::Int) where {FT<:AbstractFloat}

Return a expanded matrix, given
- `data` Input matrix
- `n` Integer times to expand the matrix

---
# Examples
```julia
mat_new = expand(rand(10,10), 2);
```

"""
function expand(data::Matrix{FT}, n::Int) where {FT<:AbstractFloat}
    # create a new matrix to save the data
    _mat = ones(FT, size(data,1) * n, size(data,2) * n) .* FT(NaN);
    for _i in axes(data,1), _j in axes(data,2)
        _mat[(_i-1)*n+1:_i*n,(_j-1)*n+1:_j*n] .= data[_i,_j];
    end;

    return _mat
end


"""

    truncate(data::Matrix{FT}, n::Int) where {FT<:AbstractFloat}

Return a truncated matrix, given
- `data` Input matrix
- `n` Integer times to truncate the matrix

---
# Examples
```julia
mat_new = truncate(rand(10,10), 2);
```

"""
function truncate(data::Matrix{FT}, n::Int) where {FT<:AbstractFloat}
    # make sure input data has higher spatial resolution than target
    @assert size(data,1) % n == 0 "Target resolution should be an integer division of the input!";
    @assert size(data,2) % n == 0 "Target resolution should be an integer division of the input!";

    # create a new matrix to save the data
    _mat = ones(FT, Int(size(data,1)/n), Int(size(data,2)/n)) .* FT(NaN);
    for _i in axes(_mat,1), _j in axes(_mat,2)
        _mat[_i,_j] = nanmean(data[(_i-1)*n+1:_i*n,(_j-1)*n+1:_j*n]);
    end;

    return _mat
end


"""

This function regrids the input datset to a spatially coaser one

    $(METHODLIST)

"""
function regrid end


"""

    regrid(data::Matrix{FT}, division::Int = 1) where {FT<:AbstractFloat}
    regrid(data::Array{FT,3}, division::Int = 1) where {FT<:AbstractFloat}
    regrid(data::Matrix{FT}, newsize::Tuple{Int,Int}; expansion::Union{Int,Nothing} = nothing) where {FT<:AbstractFloat}
    regrid(data::Array{FT,3}, newsize::Tuple{Int,Int}; expansion::Union{Int,Nothing} = nothing) where {FT<:AbstractFloat}

Return the regridded dataset, given
- `data` Input dataset, 2D or 3D
- `division` Spatial resolution is `1/division` degree (integer truncation or expansion)
- `newsize` Target 2D size of the map (not limited to integer truncation or expansion)
- `expansion` Data will be expanded before truncation (psudo super sampling, default is nothing)

---
# Examples
```julia
data_2d = rand(720,360);
data_3d = rand(720,360,2);
new_2d = regrid(data_2d, 1);
new_3d = regrid(data_3d, 1);
new_2d = regrid(data_2d, 4);
new_3d = regrid(data_3d, 4);
new_2d = regrid(data_2d, (144,96));
new_3d = regrid(data_3d, (144,96));
```

"""
regrid(data::Matrix{FT}, division::Int = 1) where {FT<:AbstractFloat} = (
    # make sure input data has the right format and higher spatial resolution than target
    @assert size(data,1) == 2 * size(data,2) "1st ind should be longitude and 2nd ind should be latitude!";
    if size(data,1) >= division * 360
        @assert size(data,1) % (360 * division) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        _n = Int(size(data,1) / (360 * division));
        func = truncate;
    else
        @assert (360 * division) % size(data,1) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        _n = Int((360 * division) / size(data,1));
        func = expand;
    end;

    return func(data, _n)
);

regrid(data::Array{FT,3}, division::Int = 1) where {FT<:AbstractFloat} = (
    # make sure input data has the right format and higher spatial resolution than target
    @assert size(data,1) == 2 * size(data,2) "1st ind should be longitude and 2nd ind should be latitude!";
    if size(data,1) >= division * 360
        @assert size(data,1) % (360 * division) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        _n = Int(size(data,1) / (360 * division));
        func = truncate;
    else
        @assert (360 * division) % size(data,1) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        _n = Int((360 * division) / size(data,1));
        func = expand;
    end;

    # create a new matrix to save the data
    _regridded = ones(FT, 360*division, 180*division, size(data,3)) .* FT(NaN);
    for _i in 1:size(data,3)
        _regridded[:,:,_i] .= func(data[:,:,_i], _n);
    end;

    return _regridded
);

regrid(data::Matrix{FT}, newsize::Tuple{Int,Int}; expansion::Union{Int,Nothing} = nothing) where {FT<:AbstractFloat} = (
    _raw = isnothing(expansion) ? data : expand(data, expansion);
    _res_ini = 360 / size(_raw,1);
    _res_inj = 180 / size(_raw,2);
    _inn_lon = collect((_res_ini/2):_res_ini:360) .- 180;
    _inn_lat = collect((_res_inj/2):_res_inj:180) .- 90;
    _res_oui = 360 / newsize[1];
    _res_ouj = 180 / newsize[2];
    _out_lon = collect((_res_oui/2):_res_oui:360) .- 180;
    _out_lat = collect((_res_ouj/2):_res_ouj:180) .- 90;
    _regridded = ones(FT,newsize) .* FT(NaN);
    for _i in 1:newsize[1], _j in 1:newsize[2]
        _ii = (_out_lon[_i] - _res_oui/2 .<= _inn_lon .<= _out_lon[_i] + _res_oui/2);
        _jj = (_out_lat[_j] - _res_ouj/2 .<= _inn_lat .<= _out_lat[_j] + _res_ouj/2);
        _regridded[_i,_j] = nanmean(_raw[_ii,_jj]);
    end;

    return _regridded
);

regrid(data::Array{FT,3}, newsize::Tuple{Int,Int}; expansion::Union{Int,Nothing} = nothing) where {FT<:AbstractFloat} = (
    _regridded = ones(FT, newsize[1], newsize[2], size(data,3));
    for _i in axes(data,3)
        _regridded[:,:,_i] = regrid(data[:,:,_i], newsize; expansion = expansion);
    end;

    return _regridded
);

end # module
