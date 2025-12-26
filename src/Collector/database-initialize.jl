"""

    initialize_database!() :: Nothing

Initializes the local GriddingMachine.jl database by creating necessary directories

"""
function initialize_database!() :: Nothing
    # make sure the GriddingMachine directory exists
    mkpath(GRIDDINGMACHINE_HOME);
    mkpath(joinpath(GRIDDINGMACHINE_HOME, "cache"));
    mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));

    return nothing
end;
