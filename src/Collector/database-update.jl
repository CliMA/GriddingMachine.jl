""" Update the database of GriddingMachine.jl """
function update_database!()
    # make sure the GriddingMachine directory exists
    GRIDDINGMACHINE_HOME = joinpath(homedir(), "GriddingMachine");
    mkpath(GRIDDINGMACHINE_HOME);
    mkpath(joinpath(GRIDDINGMACHINE_HOME, "cache"));
    mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));

    # download the latest database and reload it
    download_database!();
    global YAML_DATABASE, YAML_TAGS;
    (YAML_DATABASE, YAML_TAGS) = load_database!();

    return nothing
end;
