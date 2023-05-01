#######################################################################################################################################################################################################
#
# Changes to the struct
#     2023-Mar-20: add struct for monthly carbon tracker data
#     2023-Mar-20: add constructor for CT2022MoleFfractions
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Monthly CarbonTracker dataset

$(TYPEDFIELDS)

"""
struct CarbonTracker1M
    "Label of data"
    label::String
    "Local directory to save the data"
    local_dir::String
    "Portal url"
    portal_url::String
    "Range of years"
    years::Vector{Int}
end

CT2022MoleFfractions() = (
    return CarbonTracker1M(
                "CT2022.molefrac_glb3x2",
                "/home/wyujie/DATASERVER/model/CARBONTRACKER/CT2022/monthly/",
                "https://gml.noaa.gov/aftp/products/carbontracker/co2/CT2022/molefractions/co2_total_monthly/",
                collect(2000:2020)
    )
);


#######################################################################################################################################################################################################
#
# Changes to the function
#     2023-Mar-20: move function to CARBONTRACKER project where it is first used
#
#######################################################################################################################################################################################################
"""

Fetch data from the server. Supported methods are

$(METHODLIST)

"""
function fetch_data! end


#######################################################################################################################################################################################################
#
# Changes to the method
#     2023-Mar-20: add method to fetch data from CarbonTracker
#
#######################################################################################################################################################################################################
"""

    fetch_data!(dt::CarbonTracker1M, year::Int)

Fetch data from CarbonTracker, given
- `dt` CarbonTracker1M type struct with settings
- `year` Which year of data to download

"""
fetch_data!(dt::CarbonTracker1M, year::Int) = (
    # create folder if not existing
    if !isdir(dt.local_dir)
        @info "Directory does not exist, a new directory has been created!";
        mkpath(dt.local_dir);
    end;

    # iterate through the months
    for _month in 1:12
        _url = dt.portal_url * dt.label * "_$(year)-" * lpad(_month,2,"0") * ".nc";
        _lcf = dt.local_dir * dt.label * "_$(year)-" * lpad(_month,2,"0") * ".nc";
        if Sys.which("wget") !== nothing
            if !isfile(_lcf)
                @info "Downloading $(_url), please wait as the server is slow...";
                run(`wget -q $(_url) -O $(_lcf)`);
            end;
        else
            @warn "wget not found, exit the loop";
            break;
        end;
    end;

    return nothing
);
