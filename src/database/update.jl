#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2024-Oct-28: add function to update the database
#     2025-Jun-09: use Zenodo to download the Artifacts.yaml file
#     2025-Jun-10: make a judgement of whether the database is up to date
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
    is_start = findfirst("records/", latest_record);
    is_stop= findfirst("/files/Artifacts.yaml", latest_record);
    latest_record_url = "https://zenodo.org/$(latest_record[is_start[1]:is_stop[end]])";
    latest_record_id = latest_record[is_start[end]+1:is_stop[1]-1];

    # if the id is the same as the last one, do nothing
    if latest_record_id == ZENODO_RECORD
        @info "The Artifacts.yaml file is already up to date (record $(latest_record_id))!";

        return nothing;
    end;

    # download the Artifacts.yaml file
    @info "Downloading the latest Artifacts.yaml (record $(latest_record_id)) from: $latest_record_url";
    download_yaml_file = retry(delays = fill(1.0, 3)) do
        Downloads.download(latest_record_url, YAML_FILE);

        # write the latest record id to the Zenodo file
        fileio = open(ZENODO_FILE, "w");
        write(fileio, latest_record_id);
        close(fileio);
        global ZENODO_RECORD;
        ZENODO_RECORD = latest_record_id;
        @info "Downloaded the Artifacts.yaml (record $(ZENODO_RECORD)) file successfully!";
    end;
    download_yaml_file();

    global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
    YAML_DATABASE = YAML.load_file(YAML_FILE);
    YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
    YAML_TAGS = [k for k in keys(YAML_DATABASE)];

    return nothing
end;
