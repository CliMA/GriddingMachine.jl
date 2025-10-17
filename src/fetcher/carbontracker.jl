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
                joinpath(homedir(), "DATASERVER/model/CARBONTRACKER/CT2022/monthly/"),
                "https://gml.noaa.gov/aftp/products/carbontracker/co2/CT2022/molefractions/co2_total_monthly/",
                collect(2000:2020)
    )
);


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
    for imonth in 1:12
        url = dt.portal_url * dt.label * "_$(year)-" * lpad(imonth,2,"0") * ".nc";
        lcf = dt.local_dir * dt.label * "_$(year)-" * lpad(imonth,2,"0") * ".nc";
        if Sys.which("wget") !== nothing
            if !isfile(lcf)
                @info "Downloading $(url), please wait as the server is slow...";
                run(`wget -q $(url) -O $(lcf)`);
            end;
        else
            @warn "wget not found, exit the loop";
            break;
        end;
    end;

    return nothing
);
