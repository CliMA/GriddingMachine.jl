###############################################################################
#
# Fetch data from the website
#
###############################################################################
"""
    fetch_RAW(dt::MOD15A2Hv006LAI, year::Int)

Download RAW product data, given
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `year` Which year data to download
"""
function fetch_RAW(dt::MOD15A2Hv006LAI, year::Int)
    # judge if leap year
    if isleapyear(year)
        nothing;
    end
    http_loc = "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.006/";

    return nothing
end
