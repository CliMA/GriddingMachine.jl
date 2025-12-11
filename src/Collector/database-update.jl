""" Update the database of GriddingMachine.jl """
function update_database!()
    download_database!();
    global YAML_DATABASE, YAML_TAGS;
    (YAML_DATABASE, YAML_TAGS) = load_database!();

    return nothing
end;
