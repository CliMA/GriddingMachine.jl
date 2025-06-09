#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-28: add function to update the database
#     2025-Jun-09: use Zenodo to download the Artifacts.yaml file
#
#######################################################################################################################################################################################################
"""

    update_database!()

Update the database of GriddingMachine.jl

"""
function update_database!()
    # download the HTML file from Zenodo and then decode it
    html_lines = readlines(Downloads.download(YAML_URL));

    # find the first line that contains "Artifacts.yaml?download=1"
    iline_record = findfirst(line -> occursin("Artifacts.yaml?download=1", line), html_lines);
    latest_record = html_lines[iline_record];

    # find the record id from records/15622412/files/Artifacts.yaml?download=1
    i_start = findfirst("records/", latest_record)[1];
    i_stop= findfirst("Artifacts.yaml", latest_record)[end];
    latest_record_url = "https://zenodo.org/$(latest_record[i_start:i_stop])";

    # download the Artifacts.yaml file
    @info "Downloading the latest Artifacts.yaml file from: $latest_record_url";
    download_yaml_file = retry(delays = fill(1.0, 3)) do
        Downloads.download(latest_record_url, YAML_FILE);
    end;
    download_yaml_file();

    global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
    YAML_DATABASE = YAML.load_file(YAML_FILE);
    YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
    YAML_TAGS = [k for k in keys(YAML_DATABASE)];

    return nothing
end;
