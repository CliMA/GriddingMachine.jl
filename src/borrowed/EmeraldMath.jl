using Statistics: mean


"""

    nanmean(x::Array)
    nanmean(x::Number)

Return the mean of array by ommiting the NaN, given
- `x` Array of numbers, can be NaN

"""
function nanmean end

nanmean(x::Array) = (
    _x = filter(!isnan, x);

    return length(_x) == 0 ? NaN : mean( _x )
);

nanmean(x::Number) = isnan(x) ? NaN : x;
