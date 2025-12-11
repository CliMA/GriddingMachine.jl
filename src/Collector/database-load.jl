""" Load the database of GriddingMachine.jl """
function load_database!()
    # if the YAML file does not exist, download it first
    if !isfile(YAML_FILE)
        download_database!();
    end;

    # load the database from the library file
    db = read_library(YAML_FILE);
    tags = [k for k in keys(db)];

    return db, tags
end;
