"""

    CO₂_ppm(yy::Int)
    CO₂_ppm(yy::Int, mm::Int)
    CO₂_ppm(yy::Int, ::Bool)

Return the CO₂ concentration in ppm, given
- `yy` Year
- `mm` Month
- `::Bool` If true, return all monthly mean CO₂ concentration within the year

"""
function CO₂_ppm end;

CO₂_ppm(yy::Int) = CCS_1Y.MEAN[findfirst(CCS_1Y.YEAR .== yy)];

CO₂_ppm(yy::Int, mm::Int) = CCS_1M.MEAN[findfirst(CCS_1M.YEAR .== yy && CCS_1M.MONTH .== mm)];

CO₂_ppm(yy::Int, ::Bool) = (
    filtered = CCS_1M.MEAN[CCS_1M.YEAR .== yy];

    # If there is not data, return an error
    if length(filtered) == 0
        return error("No CO₂ data for year $yy");
    end;

    # if there are less than 12 data points
    if length(filtered) < 12
        extended = ones(12) .* filtered[end];
        extended[eachindex(filtered)] .= filtered;

        return extended
    end;

    # Default is to return the full year data (if length >= 12)
    return filtered
);
