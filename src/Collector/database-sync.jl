""" Synchronize the local database with the remote database and download the datasets """
function sync_database!()
    # update the database
    update_database!();

    # loop through the database and download the artifacts (sleep 1 second between each new download)
    for arttag in YAML_TAGS
        download_dataset!(arttag);
        sleep(1);
    end;

    return nothing
end;
