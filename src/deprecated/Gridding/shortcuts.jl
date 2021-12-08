#=
###############################################################################
#
# Shortcut to do all steps within one function
#
###############################################################################
"""
    process_RAW!(
                dt::MOD15A2Hv006LAI{FT},
                year::Int;
                days::Int = 8,
                zooms::Int = 12,
                nthread::Int = 4
    ) where {FT<:AbstractFloat}

Grid the data and save it to a csv file, given
- `param` Parameter sets to pass to different threads
- `dt` [`AbstractUngriddedData`](@ref) type ungridded data type
- `params` Array of `param`
- `nthread` Number of threads to run the code in parallel
"""
function process_RAW!(
            dt::AbstractUngriddedData{FT},
            year::Int;
            days::Int = 8,
            zooms::Int = 12,
            nthread::Int = 4
) where {FT<:AbstractFloat}
    fetch_RAW!(dt, year);
    params = query_RAW(dt, year, days);
    if nthread > 1
        grid_RAW!(dt, params, nthread);
    else
        grid_RAW!(dt, params);
    end
    compile_RAW!(dt, params, year, days, zooms);

    return nothing
end
=#
