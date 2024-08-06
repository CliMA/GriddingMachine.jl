module Blender

export regrid


include("borrowed/EmeraldMath.jl");


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
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
    mat = ones(FT, size(data,1) * n, size(data,2) * n) .* FT(NaN);
    for i in axes(data,1), j in axes(data,2)
        mat[(i-1)*n+1:i*n, (j-1)*n+1:j*n] .= data[i,j];
    end;

    return mat
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
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
    mat = ones(FT, Int(size(data,1)/n), Int(size(data,2)/n)) .* FT(NaN);
    for i in axes(mat,1), j in axes(mat,2)
        mat[i,j] = nanmean(data[(i-1)*n+1:i*n, (j-1)*n+1:j*n]);
    end;

    return mat
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
"""

    regrid(data::Matrix{FT}, division::Int = 1) where {FT<:AbstractFloat}
    regrid(data::Array{FT,3}, division::Int = 1) where {FT<:AbstractFloat}
    regrid(data::Matrix{FT}, newsize::Tuple{Int,Int}) where {FT<:AbstractFloat}
    regrid(data::Array{FT,3}, newsize::Tuple{Int,Int}) where {FT<:AbstractFloat}

Return the regridded dataset, given
- `data` Input dataset, 2D or 3D
- `division` Spatial resolution is `1/division` degree (integer truncation or expansion)
- `newsize` Target 2D size of the map (not limited to integer truncation or expansion)

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
function regrid end

regrid(data::Matrix{FT}, division::Int = 1) where {FT<:AbstractFloat} = (
    # make sure input data has the right format and higher spatial resolution than target
    @assert size(data,1) == 2 * size(data,2) "1st ind should be longitude and 2nd ind should be latitude!";
    if size(data,1) >= division * 360
        @assert size(data,1) % (360 * division) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        n = Int(size(data,1) / (360 * division));
        func = truncate;
    else
        @assert (360 * division) % size(data,1) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        n = Int((360 * division) / size(data,1));
        func = expand;
    end;

    return func(data, n)
);

regrid(data::Array{FT,3}, division::Int = 1) where {FT<:AbstractFloat} = (
    # make sure input data has the right format and higher spatial resolution than target
    @assert size(data,1) == 2 * size(data,2) "1st ind should be longitude and 2nd ind should be latitude!";
    if size(data,1) >= division * 360
        @assert size(data,1) % (360 * division) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        n = Int(size(data,1) / (360 * division));
        func = truncate;
    else
        @assert (360 * division) % size(data,1) == 0 "Target resolution should be an integer expansion/truncation of the input!";
        n = Int((360 * division) / size(data,1));
        func = expand;
    end;

    # create a new matrix to save the data
    regridded = ones(FT, 360*division, 180*division, size(data,3)) .* FT(NaN);
    for i in 1:size(data,3)
        regridded[:,:,i] .= func(data[:,:,i], n);
    end;

    return regridded
);

regrid(data::Matrix{FT}, newsize::Tuple{Int,Int}) where {FT<:AbstractFloat} = (
    # expand the data when necessary
    ex1 = Int(lcm(size(data,1), newsize[1]) / size(data,1));
    ex2 = Int(lcm(size(data,2), newsize[2]) / size(data,2));
    raw = expand(data, lcm(ex1,ex2));

    res_ini = 360 / size(raw,1);
    res_inj = 180 / size(raw,2);
    inn_lon = collect((res_ini/2):res_ini:360) .- 180;
    inn_lat = collect((res_inj/2):res_inj:180) .- 90;
    res_oui = 360 / newsize[1];
    res_ouj = 180 / newsize[2];
    out_lon = collect((res_oui/2):res_oui:360) .- 180;
    out_lat = collect((res_ouj/2):res_ouj:180) .- 90;
    regridded = ones(FT,newsize) .* FT(NaN);
    for i in 1:newsize[1], j in 1:newsize[2]
        ii = (out_lon[i] - res_oui/2 .<= inn_lon .<= out_lon[i] + res_oui/2);
        jj = (out_lat[j] - res_ouj/2 .<= inn_lat .<= out_lat[j] + res_ouj/2);
        regridded[i,j] = nanmean(raw[ii,jj]);
    end;

    return regridded
);

regrid(data::Array{FT,3}, newsize::Tuple{Int,Int}) where {FT<:AbstractFloat} = (
    regridded = ones(FT, newsize[1], newsize[2], size(data,3));
    for i in axes(data,3)
        regridded[:,:,i] = regrid(data[:,:,i], newsize);
    end;

    return regridded
);


end # module
