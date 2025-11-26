""" Load the database of GriddingMachine.jl """
function load_database!()
    # if the YAML file does not exist, download it first
    if !isfile(YAML_FILE)
        download_database!();
    end;

    # load the database from the library file
    global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
    YAML_DATABASE = read_library(YAML_FILE);
    YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
    YAML_TAGS = [k for k in keys(YAML_DATABASE)];

    return nothing
end;
