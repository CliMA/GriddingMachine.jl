#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-28: add function to update the database
#
#######################################################################################################################################################################################################
"""

    update_database!()

Update the database of GriddingMachine.jl

"""
function update_database!()
    download_yaml_file = retry(delays = fill(1.0, 3)) do
        Downloads.download(YAML_URL, YAML_FILE);
    end;
    download_yaml_file();

    global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
    YAML_DATABASE = YAML.load_file(YAML_FILE);
    YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
    YAML_TAGS = [k for k in keys(YAML_DATABASE)];

    return nothing
end;
