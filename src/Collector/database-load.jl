""" Load the database of GriddingMachine.jl """
function load_database!()
    # always make sure the database is initialized
    initialize_database!();

    # if the YAML file does not exist, download it first
    isfile(YAML_FILE) ? nothing : download_database!();

    # load the database from the library file
    db = read_library(YAML_FILE);
    tags = [k for k in keys(db)];

    return db, tags
end;
